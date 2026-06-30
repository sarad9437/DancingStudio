import { useState } from "react";

function EyeOpen() {
    return (
        <svg width="17" height="17" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="1.8"
            strokeLinecap="round" strokeLinejoin="round">
            <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z" />
            <circle cx="12" cy="12" r="3" />
        </svg>
    );
}

function EyeClosed() {
    return (
        <svg width="17" height="17" viewBox="0 0 24 24" fill="none"
            stroke="currentColor" strokeWidth="1.8"
            strokeLinecap="round" strokeLinejoin="round">
            <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94" />
            <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19" />
            <line x1="1" y1="1" x2="23" y2="23" />
        </svg>
    );
}

export default function PasswordInput({ value, onChange, placeholder, className = "", onFocus, onBlur, required = false }) {
    const [shown, setShown] = useState(false);

    return (
        <div style={{ position: "relative" }}>
            <input
                className={className || ""}
                type={shown ? "text" : "password"}
                placeholder={placeholder}
                value={value}
                onChange={onChange}
                onFocus={onFocus}
                onBlur={onBlur}
                required={required}
                style={{ paddingRight: 42, width: "100%" }}
            />
            <button
                type="button"
                onClick={() => setShown(s => !s)}
                tabIndex={-1}
                aria-label={shown ? "Sakrij lozinku" : "Prikaži lozinku"}
                style={{
                    position:       "absolute",
                    right:          12,
                    top:            "50%",
                    transform:      "translateY(-50%)",
                    background:     "none",
                    border:         "none",
                    padding:        0,
                    cursor:         "pointer",
                    color:          "var(--brown-light)",
                    display:        "flex",
                    alignItems:     "center",
                    justifyContent: "center",
                    transition:     "color 0.2s",
                    lineHeight:     1,
                }}
                onMouseEnter={e => e.currentTarget.style.color = "var(--brown)"}
                onMouseLeave={e => e.currentTarget.style.color = "var(--brown-light)"}
            >
                {shown ? <EyeClosed /> : <EyeOpen />}
            </button>
        </div>
    );
}
