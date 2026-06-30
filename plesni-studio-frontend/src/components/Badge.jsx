export default function NivoBadge({ nivo }) {
    return (
        <span style={{
            fontFamily: 'Montserrat',
            fontSize: 12,
            background: "var(--petal)",
            padding: "2px 7px",
            borderRadius: 6,
            display: "inline-block",
        }}>
            {nivo ?? "—"}
        </span>
    );
}