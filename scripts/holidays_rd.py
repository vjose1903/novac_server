#!/usr/bin/env python3
import json
import sys


SPANISH_NAMES_BY_MONTH_DAY = {
    "01-01": "Año Nuevo",
    "01-06": "Día de los Santos Reyes",
    "01-21": "Día de Nuestra Señora de la Altagracia",
    "01-26": "Día de Duarte",
    "02-27": "Día de la Independencia Nacional",
    "05-01": "Día del Trabajo",
    "08-16": "Día de la Restauración",
    "09-24": "Día de Nuestra Señora de las Mercedes",
    "11-06": "Día de la Constitución",
    "12-25": "Día de Navidad",
}

SPANISH_NAMES_BY_ENGLISH_NAME = {
    "New Year's Day": "Año Nuevo",
    "Epiphany": "Día de los Santos Reyes",
    "Our Lady of Altagracia": "Día de Nuestra Señora de la Altagracia",
    "Duarte's Day": "Día de Duarte",
    "Independence Day": "Día de la Independencia Nacional",
    "Good Friday": "Viernes Santo",
    "Labor Day": "Día del Trabajo",
    "Corpus Christi": "Corpus Christi",
    "Restoration Day": "Día de la Restauración",
    "Our Lady of Mercedes Day": "Día de Nuestra Señora de las Mercedes",
    "Constitution Day": "Día de la Constitución",
    "Christmas Day": "Día de Navidad",
}


def spanish_holiday_name(holiday_date, name):
    name = str(name)
    month_day = holiday_date.strftime("%m-%d")
    return SPANISH_NAMES_BY_MONTH_DAY.get(month_day) or SPANISH_NAMES_BY_ENGLISH_NAME.get(name) or name


def main():
    try:
        import holidays
    except ImportError:
        print("La librería python-holidays no está instalada.", file=sys.stderr)
        return 1

    try:
        years = [int(arg) for arg in sys.argv[1:]]
    except ValueError:
        print("Todos los años deben ser enteros.", file=sys.stderr)
        return 1

    if not years:
        print("Debe indicar al menos un año.", file=sys.stderr)
        return 1

    result = []

    for year in sorted(set(years)):
        rd_holidays = holidays.country_holidays("DO", years=[year])

        for holiday_date, name in sorted(rd_holidays.items()):
            spanish_name = spanish_holiday_name(holiday_date, name)
            result.append({
                "country_code": "DO",
                "date": holiday_date.isoformat(),
                "observed_date": None,
                "name": spanish_name,
                "year": holiday_date.year,
                "source": "python_holidays",
                "metadata": {
                    "original_name": str(name)
                }
            })

    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
