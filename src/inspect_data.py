from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parents[1]
RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"

DATASETS = {
    "collisions": RAW_DATA_DIR / "collisions_2020_2024.csv",
    "casualties": RAW_DATA_DIR / "casualties_2020_2024.csv",
    "vehicles": RAW_DATA_DIR / "vehicles_2020_2024.csv",
}


def inspect_dataset(name: str, file_path: Path) -> None:
    """Display basic information about one road-safety dataset."""

    print("\n" + "=" * 70)
    print(name.upper())
    print("=" * 70)

    if not file_path.exists():
        print(f"File not found: {file_path}")
        return

    dataframe = pd.read_csv(file_path, low_memory=False)

    print(f"File: {file_path.name}")
    print(f"Rows: {len(dataframe):,}")
    print(f"Columns: {len(dataframe.columns):,}")

    print("\nColumn names:")
    for column in dataframe.columns:
        print(f"  - {column}")

    print("\nFirst five rows:")
    print(dataframe.head().to_string())

    if "collision_year" in dataframe.columns:
        print("\nRecords by year:")
        print(
            dataframe["collision_year"]
            .value_counts(dropna=False)
            .sort_index()
            .to_string()
        )

    print("\nColumns with the most missing values:")
    missing_values = (
        dataframe.isna()
        .sum()
        .sort_values(ascending=False)
        .head(10)
    )
    print(missing_values.to_string())


def main() -> None:
    for dataset_name, dataset_path in DATASETS.items():
        inspect_dataset(dataset_name, dataset_path)


if __name__ == "__main__":
    main()
