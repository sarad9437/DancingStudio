export default function Reflektori({ darkMode, onToggle }) {

    const Spotlight = ({ src, alt }) => (
        <div
            onClick={onToggle}
            title={darkMode ? "Prebaci na svetli mod" : "Prebaci na tamni mod"}
            style={{
                pointerEvents: "all",
                cursor: "pointer",
                position: "relative",
                display: "flex",
                flexDirection: "column",
                alignItems: "center",
                width: 150,
            }}
        >
            <img
                src={src}
                alt={alt}
                style={{
                    width: 150,
                    height: "auto",
                    display: "block",
                    filter: "none",
                }}
            />

           
            <div style={{
                position: "absolute",
                top: "72%",
                left: "50%",
                transform: "translateX(-50%)",
                width: 0,
                height: 0,
                borderLeft: "130px solid transparent",
                borderRight: "130px solid transparent",
                borderBottom: "420px solid rgba(255,245,220,0.18)",
                filter: "blur(28px)",
                pointerEvents: "none",
                opacity: darkMode ? 0 : 1,
                transition: "opacity 0.6s ease",
            }} />
            <div style={{
                position: "absolute",
                top: "72%",
                left: "50%",
                transform: "translateX(-50%)",
                width: 0,
                height: 0,
                borderLeft: "70px solid transparent",
                borderRight: "70px solid transparent",
                borderBottom: "340px solid rgba(255,250,235,0.13)",
                filter: "blur(14px)",
                pointerEvents: "none",
                opacity: darkMode ? 0 : 1,
                transition: "opacity 0.6s ease",
            }} />
            <div style={{
                position: "absolute",
                top: "72%",
                left: "50%",
                transform: "translateX(-50%)",
                width: 0,
                height: 0,
                borderLeft: "35px solid transparent",
                borderRight: "35px solid transparent",
                borderBottom: "260px solid rgba(255,255,245,0.10)",
                filter: "blur(6px)",
                pointerEvents: "none",
                opacity: darkMode ? 0 : 1,
                transition: "opacity 0.6s ease",
            }} />
        </div>
    );

    return (
        <div style={{
            position: "absolute",
            bottom: 0,
            left: 0,
            right: 0,
            height: 0,
            display: "flex",
            justifyContent: "space-between",
            paddingLeft: 0,
            paddingRight: 0,
            zIndex: 190,
            pointerEvents: "none",
            overflow: "visible",
        }}>
            <Spotlight src="/reflektor-levo.png" alt="Reflektor levo" />
            <Spotlight src="/reflektor-desno.png" alt="Reflektor desno" />
        </div>
    );
}