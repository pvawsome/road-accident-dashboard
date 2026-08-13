from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"


def load_data() -> tuple[pd.DataFrame, pd.DataFrame, pd.DataFrame]:
    """Load only the columns required for initial validation."""

    collisions = pd.read_csv(
        RAW_DATA_DIR / "collisions_2020_2024.csv",
        usecols=[
            "collision_index",
            "collision_year",
            "number_of_vehicles",
            "number_of_casualties",
            "collision_severity",
        ],
        low_memory=False,
    )

    casualties = pd.read_csv(
        RAW_DATA_DIR / "casualties_2020_2024.csv",
        usecols=[
            "collision_index",
            "collision_year",
            "casualty_reference",
            "casualty_severity",
            "casualty_type",
            "vehicle_reference",
        ],
        low_memory=False,
    )

    vehicles = pd.read_csv(
        RAW_DATA_DIR / "vehicles_2020_2024.csv",
        usecols=[
            "collision_index",
            "collision_year",
            "vehicle_reference",
            "vehicle_type",
        ],
        low_memory=False,
    )

    return collisions, casualties, vehicles


def main() -> None:
    collisions, casualties, vehicles = load_data()

    casualties["casualty_key"] = (
        casualties["collision_index"].astype(str)
        + "-"
        + casualties["casualty_reference"].astype(str)
    )

    vehicles["vehicle_key"] = (
        vehicles["collision_index"].astype(str)
        + "-"
        + vehicles["vehicle_reference"].astype(str)
    )

    print("=" * 70)
    print("BASIC COUNTS")
    print("=" * 70)
    print(f"Collision rows: {len(collisions):,}")
    print(f"Distinct collisions: {collisions['collision_index'].nunique():,}")
    print(f"Casualty rows: {len(casualties):,}")
    print(f"Distinct casualties: {casualties['casualty_key'].nunique():,}")
    print(f"Vehicle rows: {len(vehicles):,}")
    print(f"Distinct vehicles: {vehicles['vehicle_key'].nunique():,}")

    print("\n" + "=" * 70)
    print("DUPLICATE KEYS")
    print("=" * 70)
    print(
        "Duplicate collision indexes:",
        collisions["collision_index"].duplicated().sum(),
    )
    print(
        "Duplicate casualty keys:",
        casualties["casualty_key"].duplicated().sum(),
    )
    print(
        "Duplicate vehicle keys:",
        vehicles["vehicle_key"].duplicated().sum(),
    )

    print("\n" + "=" * 70)
    print("UNMATCHED RECORDS")
    print("=" * 70)

    collision_ids = set(collisions["collision_index"])

    unmatched_casualties = (
        ~casualties["collision_index"].isin(collision_ids)
    ).sum()

    unmatched_vehicles = (
        ~vehicles["collision_index"].isin(collision_ids)
    ).sum()

    print(f"Casualties without a collision: {unmatched_casualties:,}")
    print(f"Vehicles without a collision: {unmatched_vehicles:,}")

    print("\n" + "=" * 70)
    print("RECONCILIATION")
    print("=" * 70)

    reported_casualties = collisions["number_of_casualties"].sum()
    reported_vehicles = collisions["number_of_vehicles"].sum()

    print(f"Casualties reported by collision table: {reported_casualties:,}")
    print(f"Rows in casualty table: {len(casualties):,}")
    print(f"Difference: {reported_casualties - len(casualties):,}")

    print(f"\nVehicles reported by collision table: {reported_vehicles:,}")
    print(f"Rows in vehicle table: {len(vehicles):,}")
    print(f"Difference: {reported_vehicles - len(vehicles):,}")

    print("\n" + "=" * 70)
    print("COUNTS BY YEAR")
    print("=" * 70)

    yearly_summary = pd.DataFrame(
        {
            "collisions": collisions.groupby("collision_year")[
                "collision_index"
            ].nunique(),
            "casualties": casualties.groupby("collision_year")[
                "casualty_key"
            ].nunique(),
            "vehicles": vehicles.groupby("collision_year")[
                "vehicle_key"
            ].nunique(),
        }
    )

    print(yearly_summary.to_string())


if __name__ == "__main__":
    main()
