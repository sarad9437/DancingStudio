import { registerLocale } from "react-datepicker";

const srCyrillic = {
    localize: {
        month: n => [
            "Јануар", "Фебруар", "Март", "Април", "Мај", "Јун",
            "Јул", "Август", "Септембар", "Октобар", "Новембар", "Децембар"
        ][n],
        day: n => ["Не", "По", "Ут", "Ср", "Че", "Пе", "Су"][n],
        dayPeriod: h => h,
        ordinalNumber: n => `${n}.`,
        era: n => ["пре н.е.", "н.е."][n],
        quarter: n => `${n}. квартал`,
    },
    formatLong: {
        date: () => "dd.MM.yyyy.",
        time: () => "HH:mm",
        dateTime: () => "dd.MM.yyyy. HH:mm",
    },
    match: {
        month:       () => ({ value: 0, rest: "" }),
        day:         () => ({ value: 0, rest: "" }),
        dayPeriod:   () => ({ value: "am", rest: "" }),
        ordinalNumber: (str) => ({ value: parseInt(str), rest: "" }),
        era:         () => ({ value: 1, rest: "" }),
        quarter:     () => ({ value: 1, rest: "" }),
    },
    options: {
        weekStartsOn: 1,   
        firstWeekContainsDate: 4,
    },
};

registerLocale("sr-Cyrl", srCyrillic);

export default "sr-Cyrl";
