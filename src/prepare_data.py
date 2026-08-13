from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DIR = PROJECT_ROOT / "data" / "raw"
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"
CLEAN_DIR = PROCESSED_DIR / "clean"
SUMMARY_DIR = PROCESSED_DIR / "summaries"
LOOKUP_PATH = PROCESSED_DIR / "lookups" / "all_lookup_codes.csv"


COLLISION_COLUMNS = [
    "collision_index",
    "collision_year",
    "collision_severity",
    "number_of_vehicles",
    "number_of_casualties",
    "date",
    "day_of_week",
    "time",
    "longitude",
    "latitude",
    "local_authority_highway_current",
    "road_type",
    "speed_limit",
    "light_conditions",
    "weather_conditions",
    "road_surface_conditions",
    "urban_or_rural_area",
]

CASUALTY_COLUMNS = [
    "collision_index",
    "collision_year",
    "vehicle_reference",
    "casualty_reference",
    "casualty_class",
    "sex_of_casualty",
    "age_of_casualty",
    "age_band_of_casualty",
    "casualty_severity",
    "casualty_type",
]

VEHICLE_COLUMNS = [
    "collision_index",
    "collision_year",
    "vehicle_reference",
    "vehicle_type",
    "sex_of_driver",
    "age_of_driver",
    "age_band_of_driver",
    "engine_capacity_cc",
    "age_of_vehicle",
    "generic_make_model",
    "escooter_flag",
]


def normalize_codes(series: pd.Series) -> pd.Series:
    """Convert category codes into consistent string values."""

    return (
        series.astype("string")
        .str.strip()
        .str.replace(r"\.0$", "", regex=True)
    )


def add_lookup_label(
    dataframe: pd.DataFrame,
    lookups: pd.DataFrame,
    table_name: str,
    field_name: str,
) -> None:
    """Add a readable label column for a coded field."""

    field_lookup = lookups[
        (lookups["table"] == table_name)
        & (lookups["field_name"] == field_name)
    ]

    if field_lookup.empty:
        raise ValueError(
            f"No lookup values found for {table_name}.{field_name}"
        )

    mapping = dict(
        zip(
            field_lookup["code"].astype("string"),
            field_lookup["label"],
        )
    )

    label_column = f"{field_name}_label"

    dataframe[label_column] = (
        normalize_codes(dataframe[field_name])
        .map(mapping)
        .fillna("Unknown")
    )


def load_data() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Load the source files using only dashboard-relevant columns."""

    collisions = pd.read_csv(
        RAW_DIR / "collisions_2020_2024.csv",
        usecols=COLLISION_COLUMNS,
        low_memory=False,
    )

    casualties = pd.read_csv(
        RAW_DIR / "casualties_2020_2024.csv",
        usecols=CASUALTY_COLUMNS,
        low_memory=False,
    )

    vehicles = pd.read_csv(
        RAW_DIR / "vehicles_2020_2024.csv",
        usecols=VEHICLE_COLUMNS,
        low_memory=False,
    )

    return collisions, casualties, vehicles


def prepare_collisions(
    collisions: pd.DataFrame,
    lookups: pd.DataFrame,
) -> pd.DataFrame:
    """Clean collision data and create date-related fields."""

    collisions = collisions.copy()

    collisions["collision_date"] = pd.to_datetime(
        collisions.pop("date"),
        format="%d/%m/%Y",
        errors="coerce",
    )

    collisions["collision_time"] = collisions.pop("time").astype("string")

    parsed_time = pd.to_datetime(
        collisions["collision_time"],
        format="%H:%M",
        errors="coerce",
    )

    collisions["collision_hour"] = parsed_time.dt.hour.astype("Int64")
    collisions["month_number"] = (
        collisions["collision_date"].dt.month.astype("Int64")
    )
    collisions["month_name"] = collisions["collision_date"].dt.month_name()
    collisions["quarter"] = (
        "Q"
        + collisions["collision_date"]
        .dt.quarter.astype("Int64")
        .astype("string")
    )

    collision_lookup_fields = [
        "collision_severity",
        "day_of_week",
        "road_type",
        "light_conditions",
        "weather_conditions",
        "road_surface_conditions",
        "urban_or_rural_area",
    ]

    for field_name in collision_lookup_fields:
        add_lookup_label(
            collisions,
            lookups,
            "collision",
            field_name,
        )

    return collisions


def prepare_casualties(
    casualties: pd.DataFrame,
    lookups: pd.DataFrame,
) -> pd.DataFrame:
    """Clean casualty data and create unique keys."""

    casualties = casualties.copy()

    casualties["casualty_key"] = (
        casualties["collision_index"].astype("string")
        + "-"
        + casualties["casualty_reference"].astype("string")
    )

    casualties["vehicle_key"] = (
        casualties["collision_index"].astype("string")
        + "-"
        + casualties["vehicle_reference"].astype("string")
    )

    casualty_lookup_fields = [
        "casualty_class",
        "sex_of_casualty",
        "age_band_of_casualty",
        "casualty_severity",
        "casualty_type",
    ]

    for field_name in casualty_lookup_fields:
        add_lookup_label(
            casualties,
            lookups,
            "casualty",
            field_name,
        )

    return casualties


def prepare_vehicles(
    vehicles: pd.DataFrame,
    lookups: pd.DataFrame,
) -> pd.DataFrame:
    """Clean vehicle data and create unique keys."""

    vehicles = vehicles.copy()

    vehicles["vehicle_key"] = (
        vehicles["collision_index"].astype("string")
        + "-"
        + vehicles["vehicle_reference"].astype("string")
    )

    vehicle_lookup_fields = [
        "vehicle_type",
        "sex_of_driver",
        "age_band_of_driver",
    ]

    for field_name in vehicle_lookup_fields:
        add_lookup_label(
            vehicles,
            lookups,
            "vehicle",
            field_name,
        )

    return vehicles


def validate_keys(
    collisions: pd.DataFrame,
    casualties: pd.DataFrame,
    vehicles: pd.DataFrame,
) -> None:
    """Stop processing if important keys contain duplicates."""

    duplicate_collisions = collisions["collision_index"].duplicated().sum()
    duplicate_casualties = casualties["casualty_key"].duplicated().sum()
    duplicate_vehicles = vehicles["vehicle_key"].duplicated().sum()

    print("\nKey validation:")
    print(f"Duplicate collision keys: {duplicate_collisions:,}")
    print(f"Duplicate casualty keys: {duplicate_casualties:,}")
    print(f"Duplicate vehicle keys: {duplicate_vehicles:,}")

    if any(
        [
            duplicate_collisions,
            duplicate_casualties,
            duplicate_vehicles,
        ]
    ):
        raise ValueError("Duplicate primary keys were detected.")


def create_summaries(
    collisions: pd.DataFrame,
    casualties: pd.DataFrame,
    vehicles: pd.DataFrame,
) -> pd.DataFrame:
    """Create KPI summaries for validation and dashboard planning."""

    collision_summary = (
        collisions.groupby("collision_year")
        .agg(
            total_collisions=("collision_index", "nunique"),
            reported_casualties=("number_of_casualties", "sum"),
            reported_vehicles=("number_of_vehicles", "sum"),
        )
        .reset_index()
    )

    casualty_summary = (
        casualties.groupby("collision_year")
        .agg(total_casualties=("casualty_key", "nunique"))
        .reset_index()
    )

    vehicle_summary = (
        vehicles.groupby("collision_year")
        .agg(total_vehicles=("vehicle_key", "nunique"))
        .reset_index()
    )

    yearly_kpis = (
        collision_summary
        .merge(casualty_summary, on="collision_year")
        .merge(vehicle_summary, on="collision_year")
    )

    yearly_kpis["collision_yoy_percent"] = (
        yearly_kpis["total_collisions"].pct_change() * 100
    ).round(2)

    yearly_kpis["casualty_yoy_percent"] = (
        yearly_kpis["total_casualties"].pct_change() * 100
    ).round(2)

    severity_summary = (
        casualties.groupby(
            ["collision_year", "casualty_severity_label"]
        )
        .agg(total_casualties=("casualty_key", "nunique"))
        .reset_index()
    )

    road_user_summary = (
        casualties.groupby(
            ["collision_year", "casualty_type_label"]
        )
        .agg(total_casualties=("casualty_key", "nunique"))
        .reset_index()
    )

    vehicle_type_summary = (
        vehicles.groupby(
            ["collision_year", "vehicle_type_label"]
        )
        .agg(total_vehicles=("vehicle_key", "nunique"))
        .reset_index()
    )

    yearly_kpis.to_csv(
        SUMMARY_DIR / "yearly_kpis.csv",
        index=False,
    )

    severity_summary.to_csv(
        SUMMARY_DIR / "casualties_by_severity.csv",
        index=False,
    )

    road_user_summary.to_csv(
        SUMMARY_DIR / "casualties_by_road_user.csv",
        index=False,
    )

    vehicle_type_summary.to_csv(
        SUMMARY_DIR / "vehicles_by_type.csv",
        index=False,
    )

    return yearly_kpis


def save_table(dataframe: pd.DataFrame, name: str) -> None:
    """Save each cleaned table as CSV and Parquet."""

    csv_path = CLEAN_DIR / f"{name}.csv"
    parquet_path = CLEAN_DIR / f"{name}.parquet"

    dataframe.to_csv(
        csv_path,
        index=False,
        date_format="%Y-%m-%d",
    )

    dataframe.to_parquet(
        parquet_path,
        index=False,
    )

    print(f"Saved {csv_path}")
    print(f"Saved {parquet_path}")


def main() -> None:
    if not LOOKUP_PATH.exists():
        raise FileNotFoundError(
            "Lookup file is missing. Run "
            "'python src/extract_lookup_tables.py' first."
        )

    CLEAN_DIR.mkdir(parents=True, exist_ok=True)
    SUMMARY_DIR.mkdir(parents=True, exist_ok=True)

    lookups = pd.read_csv(
        LOOKUP_PATH,
        dtype={"code": "string"},
    )

    collisions, casualties, vehicles = load_data()

    print("Source rows:")
    print(f"Collisions: {len(collisions):,}")
    print(f"Casualties: {len(casualties):,}")
    print(f"Vehicles: {len(vehicles):,}")

    collisions = prepare_collisions(collisions, lookups)
    casualties = prepare_casualties(casualties, lookups)
    vehicles = prepare_vehicles(vehicles, lookups)

    validate_keys(collisions, casualties, vehicles)

    yearly_kpis = create_summaries(
        collisions,
        casualties,
        vehicles,
    )

    save_table(collisions, "collisions_clean")
    save_table(casualties, "casualties_clean")
    save_table(vehicles, "vehicles_clean")

    latest_year = int(yearly_kpis["collision_year"].max())

    print("\nYearly KPI summary:")
    print(yearly_kpis.to_string(index=False))

    print(f"\nLatest validated year: {latest_year}")
    print("Data preparation completed successfully.")


if __name__ == "__main__":
    main()
