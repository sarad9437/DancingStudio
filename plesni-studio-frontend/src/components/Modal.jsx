import { useEffect, useRef } from "react";

export default function Modal({ title, onClose, children, footer }) {
    const modalRef = useRef(null);
    const onCloseRef = useRef(onClose);

    useEffect(() => {
        onCloseRef.current = onClose;
    }, [onClose]);

    useEffect(() => {
        const modal = modalRef.current;
        if (!modal) return;

        const getFocusable = () =>
            Array.from(
                modal.querySelectorAll(
                    'button, input, select, textarea, [tabindex]:not([tabindex="-1"])'
                )
            ).filter(el => !el.disabled);

        const firstInput = modal.querySelector(
            'input:not([disabled]), select:not([disabled]), textarea:not([disabled])'
        );
        if (firstInput) {
            firstInput.focus();
        } else {
            const focusable = getFocusable();
            if (focusable.length > 0) focusable[0].focus();
        }

        const handleKeyDown = e => {
            if (e.key === "Escape") {
                onCloseRef.current();
                return;
            }

            if (e.key === "Tab") {
                const focusable = getFocusable();
                if (focusable.length === 0) return;

                const first = focusable[0];
                const last = focusable[focusable.length - 1];

                if (e.shiftKey) {
                    if (document.activeElement === first) {
                        e.preventDefault();
                        last.focus();
                    }
                } else {
                    if (document.activeElement === last) {
                        e.preventDefault();
                        first.focus();
                    }
                }
            }
        };

        document.addEventListener("keydown", handleKeyDown);
        return () => {
            document.removeEventListener("keydown", handleKeyDown);
        };
    }, []); 

    return (
        <div
            className="backdrop"
            onClick={e => e.target === e.currentTarget && onCloseRef.current()}
        >
            <div
                className="modal"
                ref={modalRef}
                role="dialog"
                aria-modal="true"
                aria-label={title}
            >
                <div className="mh">
                    <h3>{title}</h3>
                    <button className="mx" onClick={onClose} aria-label="Zatvori">
                        ✕
                    </button>
                </div>
                <div className="mb">
                    {children}
                </div>
                {footer && <div className="mf">{footer}</div>}
            </div>
        </div>
    );
}