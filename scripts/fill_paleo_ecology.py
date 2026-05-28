#!/usr/bin/env python3
from pathlib import Path
import sys
import yaml


INPUT_PATH = Path("data/palaeo_ecology.yaml")


COMMON_SOURCES = {
    "temperature": "Scotese et al. 2021 Phanerozoic temperature reconstruction",
    "co2": "Foster et al. 2017 Phanerozoic CO2 synthesis",
    "sea_level_paleozoic": "Haq and Schutter 2008 Paleozoic sea-level synthesis",
    "sea_level_phanerozoic": "van der Meer et al. 2022 Phanerozoic sea-level synthesis",
    "holocene": "Holocene climate and sea-level synthesis",
}


def path_contains(row, name):
    return name in row.get("path", [])


def stage_is(row, *names):
    return row.get("stage") in names


def is_blank_environment(row):
    return (
        row.get("avg_temp_delta_c") is None
        and row.get("avg_humidity_delta_percent") is None
        and row.get("avg_co2_delta_percent") is None
        and row.get("sea_level_delta_m") is None
    )


def apply_values(
    row,
    avg_temp_delta_c,
    avg_humidity_delta_percent,
    avg_co2_delta_percent,
    sea_level_delta_m,
    icehouse_greenhouse_state,
    confidence,
    note,
    sources,
    overwrite=False,
):
    if not overwrite and not is_blank_environment(row):
        return False

    row["avg_temp_delta_c"] = avg_temp_delta_c
    row["avg_humidity_delta_percent"] = avg_humidity_delta_percent
    row["avg_co2_delta_percent"] = avg_co2_delta_percent
    row["sea_level_delta_m"] = sea_level_delta_m
    row["icehouse_greenhouse_state"] = icehouse_greenhouse_state
    row["confidence"] = confidence
    row["note"] = note
    row["sources"] = sources
    return True


def values_for_row(row):
    stage = row.get("stage")
    path = row.get("path", [])

    if path_contains(row, "Cambrian"):
        return {
            "avg_temp_delta_c": +8.0,
            "avg_humidity_delta_percent": +6.0,
            "avg_co2_delta_percent": +0.36,
            "sea_level_delta_m": +80.0,
            "icehouse_greenhouse_state": "greenhouse",
            "confidence": "low",
            "note": "Broad Cambrian greenhouse estimate; stage-level values are approximate and should be refined from specialist datasets.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Ordovician"):
        if stage == "Hirnantian":
            return {
                "avg_temp_delta_c": +1.0,
                "avg_humidity_delta_percent": -5.0,
                "avg_co2_delta_percent": +0.10,
                "sea_level_delta_m": -50.0,
                "icehouse_greenhouse_state": "icehouse",
                "confidence": "moderate",
                "note": "Hirnantian values reflect the short-lived end-Ordovician glaciation and associated sea-level fall.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["sea_level_paleozoic"],
                ],
            }

        return {
            "avg_temp_delta_c": +7.0,
            "avg_humidity_delta_percent": +5.0,
            "avg_co2_delta_percent": +0.32,
            "sea_level_delta_m": +120.0,
            "icehouse_greenhouse_state": "greenhouse",
            "confidence": "low",
            "note": "Broad Ordovician greenhouse and high-sea-level estimate; values are approximate at stage scale.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_paleozoic"],
            ],
        }

    if path_contains(row, "Silurian"):
        return {
            "avg_temp_delta_c": +6.0,
            "avg_humidity_delta_percent": +4.0,
            "avg_co2_delta_percent": +0.18,
            "sea_level_delta_m": +90.0,
            "icehouse_greenhouse_state": "greenhouse",
            "confidence": "low",
            "note": "Broad Silurian warm greenhouse estimate; short-term glacio-eustatic changes are not represented here.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_paleozoic"],
            ],
        }

    if path_contains(row, "Devonian"):
        if stage == "Frasnian":
            return {
                "avg_temp_delta_c": +5.0,
                "avg_humidity_delta_percent": +2.0,
                "avg_co2_delta_percent": +0.10,
                "sea_level_delta_m": +70.0,
                "icehouse_greenhouse_state": "greenhouse",
                "confidence": "low",
                "note": "Broad late Devonian estimate; reef decline and Kellwasser environmental stress are not captured by average values alone.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_paleozoic"],
                ],
            }

        if stage == "Famennian":
            return {
                "avg_temp_delta_c": +3.0,
                "avg_humidity_delta_percent": +1.0,
                "avg_co2_delta_percent": +0.08,
                "sea_level_delta_m": +40.0,
                "icehouse_greenhouse_state": "transitional",
                "confidence": "low",
                "note": "Broad latest Devonian estimate; Hangenberg cooling and extinction stress should be represented separately as events.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_paleozoic"],
                ],
            }

        return {
            "avg_temp_delta_c": +5.0,
            "avg_humidity_delta_percent": +3.0,
            "avg_co2_delta_percent": +0.12,
            "sea_level_delta_m": +80.0,
            "icehouse_greenhouse_state": "greenhouse",
            "confidence": "low",
            "note": "Broad Devonian greenhouse estimate; regional humidity and sea-level conditions varied substantially.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_paleozoic"],
            ],
        }

    if path_contains(row, "Carboniferous"):
        if stage == "Tournaisian":
            return {
                "avg_temp_delta_c": +3.0,
                "avg_humidity_delta_percent": +4.0,
                "avg_co2_delta_percent": +0.06,
                "sea_level_delta_m": +60.0,
                "icehouse_greenhouse_state": "transitional",
                "confidence": "low",
                "note": "Early Carboniferous estimate during transition toward late Paleozoic icehouse conditions.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_paleozoic"],
                ],
            }

        if stage in {"Visean", "Serpukhovian"}:
            return {
                "avg_temp_delta_c": +2.0,
                "avg_humidity_delta_percent": +6.0,
                "avg_co2_delta_percent": +0.04,
                "sea_level_delta_m": +50.0,
                "icehouse_greenhouse_state": "cool_greenhouse",
                "confidence": "low",
                "note": "Mississippian values reflect humid equatorial coal-forming settings superimposed on broad global cooling.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_paleozoic"],
                ],
            }

        return {
            "avg_temp_delta_c": -1.0,
            "avg_humidity_delta_percent": +5.0,
            "avg_co2_delta_percent": +0.02,
            "sea_level_delta_m": +25.0,
            "icehouse_greenhouse_state": "icehouse",
            "confidence": "low",
            "note": "Pennsylvanian values reflect late Paleozoic icehouse climate with humid tropical coal swamps and strong regional contrasts.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_paleozoic"],
            ],
        }

    if path_contains(row, "Permian"):
        if stage in {"Asselian", "Sakmarian", "Artinskian", "Kungurian"}:
            return {
                "avg_temp_delta_c": +0.5,
                "avg_humidity_delta_percent": -2.0,
                "avg_co2_delta_percent": +0.03,
                "sea_level_delta_m": +10.0,
                "icehouse_greenhouse_state": "icehouse",
                "confidence": "low",
                "note": "Early Permian values reflect late Paleozoic icehouse conditions with increasing continental aridity.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_paleozoic"],
                ],
            }

        if stage in {"Roadian", "Wordian", "Capitanian"}:
            return {
                "avg_temp_delta_c": +3.0,
                "avg_humidity_delta_percent": -3.0,
                "avg_co2_delta_percent": +0.06,
                "sea_level_delta_m": +20.0,
                "icehouse_greenhouse_state": "transitional",
                "confidence": "low",
                "note": "Middle Permian estimate during warming and weakening of late Paleozoic icehouse conditions.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_paleozoic"],
                ],
            }

        return {
            "avg_temp_delta_c": +5.0,
            "avg_humidity_delta_percent": -4.0,
            "avg_co2_delta_percent": +0.10,
            "sea_level_delta_m": +15.0,
            "icehouse_greenhouse_state": "greenhouse",
            "confidence": "low",
            "note": "Late Permian values reflect warming, aridity, and environmental instability before the end-Permian crisis.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_paleozoic"],
            ],
        }

    if path_contains(row, "Triassic"):
        if stage == "Induan":
            return {
                "avg_temp_delta_c": +8.0,
                "avg_humidity_delta_percent": -3.0,
                "avg_co2_delta_percent": +0.14,
                "sea_level_delta_m": +20.0,
                "icehouse_greenhouse_state": "hothouse",
                "confidence": "low",
                "note": "Induan values reflect severe post-end-Permian greenhouse conditions and ecological stress.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_phanerozoic"],
                ],
            }

        return {
            "avg_temp_delta_c": +7.0,
            "avg_humidity_delta_percent": -2.0,
            "avg_co2_delta_percent": +0.12,
            "sea_level_delta_m": +40.0,
            "icehouse_greenhouse_state": "hothouse",
            "confidence": "low",
            "note": "Broad Triassic hothouse estimate; aridity was strong across many continental interiors.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Jurassic"):
        return {
            "avg_temp_delta_c": +6.0,
            "avg_humidity_delta_percent": +4.0,
            "avg_co2_delta_percent": +0.12,
            "sea_level_delta_m": +80.0,
            "icehouse_greenhouse_state": "greenhouse",
            "confidence": "low",
            "note": "Broad Jurassic greenhouse estimate; short events such as the Toarcian OAE should be treated separately.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Cretaceous"):
        if path_contains(row, "Lower"):
            return {
                "avg_temp_delta_c": +7.0,
                "avg_humidity_delta_percent": +5.0,
                "avg_co2_delta_percent": +0.14,
                "sea_level_delta_m": +90.0,
                "icehouse_greenhouse_state": "greenhouse",
                "confidence": "low",
                "note": "Broad Early Cretaceous greenhouse estimate with rising sea levels and regional oceanic anoxic events.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_phanerozoic"],
                ],
            }

        return {
            "avg_temp_delta_c": +9.0,
            "avg_humidity_delta_percent": +7.0,
            "avg_co2_delta_percent": +0.16,
            "sea_level_delta_m": +140.0,
            "icehouse_greenhouse_state": "hothouse",
            "confidence": "low",
            "note": "Broad Late Cretaceous hothouse estimate with very high sea levels; stage-scale variation is simplified.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if stage in {"Danian", "Selandian", "Thanetian"}:
        return {
            "avg_temp_delta_c": +5.0,
            "avg_humidity_delta_percent": +4.0,
            "avg_co2_delta_percent": +0.06,
            "sea_level_delta_m": +60.0,
            "icehouse_greenhouse_state": "greenhouse",
            "confidence": "moderate",
            "note": "Paleocene estimate after K-Pg recovery and before the early Eocene climatic optimum.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Eocene"):
        if stage == "Priabonian":
            return {
                "avg_temp_delta_c": +5.0,
                "avg_humidity_delta_percent": +2.0,
                "avg_co2_delta_percent": +0.04,
                "sea_level_delta_m": +40.0,
                "icehouse_greenhouse_state": "transitional",
                "confidence": "moderate",
                "note": "Late Eocene values reflect cooling toward the Eocene-Oligocene transition and Antarctic glaciation.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_phanerozoic"],
                ],
            }

        return {
            "avg_temp_delta_c": +9.0,
            "avg_humidity_delta_percent": +7.0,
            "avg_co2_delta_percent": +0.08,
            "sea_level_delta_m": +70.0,
            "icehouse_greenhouse_state": "hothouse",
            "confidence": "moderate",
            "note": "Eocene values reflect globally warm greenhouse to hothouse conditions, especially in the early Eocene.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Oligocene"):
        return {
            "avg_temp_delta_c": +2.0,
            "avg_humidity_delta_percent": -1.0,
            "avg_co2_delta_percent": +0.02,
            "sea_level_delta_m": +20.0,
            "icehouse_greenhouse_state": "icehouse",
            "confidence": "moderate",
            "note": "Oligocene values reflect cooler icehouse conditions after Antarctic glaciation began.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Miocene"):
        if stage in {"Aquitanian", "Burdigalian", "Langhian"}:
            return {
                "avg_temp_delta_c": +3.0,
                "avg_humidity_delta_percent": +2.0,
                "avg_co2_delta_percent": +0.01,
                "sea_level_delta_m": +25.0,
                "icehouse_greenhouse_state": "cool_greenhouse",
                "confidence": "moderate",
                "note": "Early to middle Miocene values include the Miocene climatic optimum and relatively warm global conditions.",
                "sources": [
                    COMMON_SOURCES["temperature"],
                    COMMON_SOURCES["co2"],
                    COMMON_SOURCES["sea_level_phanerozoic"],
                ],
            }

        return {
            "avg_temp_delta_c": +1.5,
            "avg_humidity_delta_percent": -1.0,
            "avg_co2_delta_percent": +0.00,
            "sea_level_delta_m": +10.0,
            "icehouse_greenhouse_state": "transitional",
            "confidence": "moderate",
            "note": "Late Miocene values reflect cooling, increasing aridity, and expansion of open habitats.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Pliocene"):
        return {
            "avg_temp_delta_c": +1.5,
            "avg_humidity_delta_percent": +0.0,
            "avg_co2_delta_percent": +0.00,
            "sea_level_delta_m": +10.0,
            "icehouse_greenhouse_state": "cool_greenhouse",
            "confidence": "moderate",
            "note": "Pliocene values reflect warmer-than-present conditions before intensification of Northern Hemisphere glaciation.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Pleistocene"):
        return {
            "avg_temp_delta_c": -2.0,
            "avg_humidity_delta_percent": -3.0,
            "avg_co2_delta_percent": -0.01,
            "sea_level_delta_m": -60.0,
            "icehouse_greenhouse_state": "icehouse",
            "confidence": "moderate",
            "note": "Pleistocene values average repeated glacial-interglacial cycles; individual interglacials were much closer to present.",
            "sources": [
                COMMON_SOURCES["temperature"],
                COMMON_SOURCES["co2"],
                COMMON_SOURCES["sea_level_phanerozoic"],
            ],
        }

    if path_contains(row, "Holocene"):
        if stage == "Greenlandian":
            return {
                "avg_temp_delta_c": -0.3,
                "avg_humidity_delta_percent": +0.0,
                "avg_co2_delta_percent": -0.01,
                "sea_level_delta_m": -20.0,
                "icehouse_greenhouse_state": "icehouse",
                "confidence": "moderate",
                "note": "Early Holocene values reflect warming after the last glacial period while sea level was still rising toward present.",
                "sources": [
                    COMMON_SOURCES["holocene"],
                    COMMON_SOURCES["co2"],
                ],
            }

        if stage == "Northgrippian":
            return {
                "avg_temp_delta_c": +0.0,
                "avg_humidity_delta_percent": +0.0,
                "avg_co2_delta_percent": -0.01,
                "sea_level_delta_m": -2.0,
                "icehouse_greenhouse_state": "icehouse",
                "confidence": "moderate",
                "note": "Middle Holocene values are close to present but still preindustrial in atmospheric CO2 terms.",
                "sources": [
                    COMMON_SOURCES["holocene"],
                    COMMON_SOURCES["co2"],
                ],
            }

        return {
            "avg_temp_delta_c": +0.5,
            "avg_humidity_delta_percent": +0.0,
            "avg_co2_delta_percent": +0.00,
            "sea_level_delta_m": +0.0,
            "icehouse_greenhouse_state": "icehouse",
            "confidence": "moderate",
            "note": "Late Holocene values are close to the present baseline; recent industrial warming is compressed into the latest part of the stage.",
            "sources": [
                COMMON_SOURCES["holocene"],
                COMMON_SOURCES["co2"],
            ],
        }

    return None


def format_signed_numbers_for_readability(text):
    # PyYAML writes positive floats as 7.0 rather than +7.0.
    # This pass keeps the YAML human-readable while still valid YAML.
    keys = [
        "avg_temp_delta_c",
        "avg_humidity_delta_percent",
        "avg_co2_delta_percent",
        "sea_level_delta_m",
    ]

    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        updated = line

        for key in keys:
            prefix = key + ": "
            if stripped.startswith(prefix):
                value = stripped[len(prefix):]
                try:
                    number = float(value)
                except ValueError:
                    break

                if number > 0:
                    leading = line[: len(line) - len(line.lstrip())]
                    updated = leading + key + ": +" + str(value)
                break

        lines.append(updated)

    return "\n".join(lines) + "\n"


def main():
    overwrite = "--overwrite" in sys.argv

    if not INPUT_PATH.exists():
        raise SystemExit("Could not find " + str(INPUT_PATH))

    data = yaml.safe_load(INPUT_PATH.read_text(encoding="utf-8"))

    rows = data.get("palaeo_ecology")
    if not isinstance(rows, list):
        raise SystemExit("Expected root key palaeo_ecology to contain a list")

    changed = 0
    skipped = 0
    unmatched = []

    for row in rows:
        values = values_for_row(row)

        if values is None:
            unmatched.append(row.get("stage", "UNKNOWN"))
            continue

        did_change = apply_values(
            row,
            avg_temp_delta_c=values["avg_temp_delta_c"],
            avg_humidity_delta_percent=values["avg_humidity_delta_percent"],
            avg_co2_delta_percent=values["avg_co2_delta_percent"],
            sea_level_delta_m=values["sea_level_delta_m"],
            icehouse_greenhouse_state=values["icehouse_greenhouse_state"],
            confidence=values["confidence"],
            note=values["note"],
            sources=values["sources"],
            overwrite=overwrite,
        )

        if did_change:
            changed += 1
        else:
            skipped += 1

    output = yaml.safe_dump(data, sort_keys=False, allow_unicode=True)
    output = format_signed_numbers_for_readability(output)
    INPUT_PATH.write_text(output, encoding="utf-8")

    print("Updated " + str(INPUT_PATH))
    print("Changed rows: " + str(changed))
    print("Skipped rows: " + str(skipped))

    if unmatched:
        print("Unmatched rows:")
        for name in unmatched:
            print("  - " + name)


if __name__ == "__main__":
    main()