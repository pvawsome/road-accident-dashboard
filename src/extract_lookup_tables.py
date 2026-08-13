from pathlib import Path
from typing import Any

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]

GUIDE_PATH = (
    PROJECT_ROOT
    / "data"
    / "raw"
    / "road_safety_data_guide_2024.xlsx"
)

OUTPUT_DIR = (
    PROJECT_ROOT
    / "data"
    / "processed"
    / "lookups"
)

TARGET_FIELDS = {
    "collision": [
        "collision_severity",
        "day_of_week",
        "road_type",
        "light_conditions",
        "weather_conditions",
        "road_surface_conditions",
        "urban_or_rural_area",
    ],
    "casualty": [
        "casualty_class",
        "sex_of_casualty",
        "age_band_of_casualty",
        "casualty_severity",
        "casualty_type",
    ],
    "vehicle": [
        "vehicle_type",
        "sex_of_driver",
        "age_band_of_driver",
    ],
}


def normalize_code(value: Any) -> str | None:
    """Convert Excel codes such as 1.0 into clean strings such as '1'."""

    if pd.isna(value):
        return None

    if isinstance(value, float) and value.is_integer():
        return str(int(value))

    return str(value).strip()


def main() -> None:
    if not GUIDE_PATH.exists():
        raise FileNotFoundError(f"Data guide not found: {GUIDE_PATH}")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    guide = pd.read_excel(
        GUIDE_PATH,
        sheet_name="2024_code_list",
        dtype=object,
    )

    guide.columns = [
        str(column).strip().lower().replace(" ", "_").replace("/", "_")
        for column in guide.columns
    ]

    print("Guide columns:")
    print(guide.columns.tolist())

    target_field_names = {
        field
        for fields in TARGET_FIELDS.values()
        for field in fields
    }

    lookups = guide[
        guide["field_name"].isin(target_field_names)
        & guide["code_format"].notna()
        & guide["label"].notna()
    ].copy()

    lookups["table"] = (
        lookups["table"]
        .astype(str)
        .str.strip()
        .str.lower()
    )

    lookups["field_name"] = (
        lookups["field_name"]
        .astype(str)
        .str.strip()
    )

    lookups["code"] = lookups["code_format"].apply(normalize_code)

    lookups["label"] = (
        lookups["label"]
        .astype(str)
        .str.strip()
    )

    output_columns = [
        "table",
        "field_name",
        "code",
        "label",
        "note",
    ]

    combined_output = OUTPUT_DIR / "all_lookup_codes.csv"

    lookups[output_columns].to_csv(
        combined_output,
        index=False,
    )

    print(f"\nCombined lookup saved to: {combined_output}")
    print(f"Total lookup rows: {len(lookups):,}")

    for table_name, fields in TARGET_FIELDS.items():
        for field_name in fields:
            field_lookup = lookups[
                (lookups["table"] == table_name)
                & (lookups["field_name"] == field_name)
            ][output_columns]

            if field_lookup.empty:
                print(
                    f"Warning: no lookup found for "
                    f"{table_name}.{field_name}"
                )
                continue

            output_path = (
                OUTPUT_DIR
                / f"{table_name}_{field_name}.csv"
            )

            field_lookup.to_csv(output_path, index=False)

            print(
                f"Created {output_path.name}: "
                f"{len(field_lookup):,} codes"
            )


if __name__ == "__main__":
    main()
