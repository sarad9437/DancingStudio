
export function formatDate(value) {
    if (!value) return "—";
    const part = String(value).slice(0, 10);
    const [y, m, d] = part.split("-");
    if (!y || !m || !d) return "—";
    return `${d}.${m}.${y}.`;
}


export function formatMonthYear(value) {
    if (!value) return "—";
    const part = String(value).slice(0, 7);
    const [y, m] = part.split("-");
    if (!y || !m) return "—";
    return `${m}.${y}.`;
}