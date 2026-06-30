import { useState, useEffect } from "react";
import { fireConfetti } from "./Confetti";

const DANCER_SRC = {
    success: "/dancer-success-green.png",
    error:   "/dancer-error-red.png",
};

function ToastItem({ toast, onRemove }) {
    const [exiting, setExiting] = useState(false);
    const [visible, setVisible] = useState(false);

    useEffect(() => {
        if (toast.type === "success") fireConfetti();
        const t0 = setTimeout(() => setVisible(true), 80);
        const t1 = setTimeout(() => setExiting(true), 3000);
        const t2 = setTimeout(() => onRemove(toast.id), 3280);
        return () => { clearTimeout(t0); clearTimeout(t1); clearTimeout(t2); };
    }, [toast.id, toast.type, onRemove]);

    const hasDancer = toast.type === "success" || toast.type === "error";

    return (
        <div
            className={`toast ${toast.type} ${exiting ? "exiting" : ""}`}
            style={{
                display:       "flex",
                alignItems:    "center",
                gap:           10,
                paddingRight:  hasDancer ? 8 : undefined,
                overflow:      "hidden",
                minHeight:     52,
            }}
        >
            <span style={{ flexShrink: 0 }}>
                {toast.type === "success" ? "✅" : toast.type === "error" ? "❌" : "ℹ️"}
            </span>

            <span style={{ flex: 1 }}>{toast.msg}</span>

            {hasDancer && (
                <img
                    src={DANCER_SRC[toast.type]}
                    alt=""
                    style={{
                        flexShrink:    0,
                        height:        80,
                        width:         "auto",
                        objectFit:     "contain",
                        alignSelf:     "stretch",
                        opacity:       visible ? 1 : 0,
                        transition:    "opacity 0.45s ease",
                        pointerEvents: "none",
                        transform:     toast.type === "success" ? "scaleX(-1)" : "none",
                    }}
                />
            )}
        </div>
    );
}

export default function Toast({ toasts, removeToast }) {
    return (
        <div className="tc">
            {toasts.map(t => (
                <ToastItem key={t.id} toast={t} onRemove={removeToast} />
            ))}
        </div>
    );
}