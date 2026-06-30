import { useState, useRef, useEffect } from "react";
import PasswordInput from "../components/PasswordInput";

const VIDEO_SRC = "/balerina_video.mp4";
const LOGO_SRC  = "/logo.png";

export default function LoginPage({ onLogin }) {
    const [email,   setEmail]   = useState("");
    const [lozinka, setLozinka] = useState("");
    const [loading, setLoading] = useState(false);
    const [greska,  setGreska]  = useState("");
    const [fokus,   setFokus]   = useState(null);
    const videoRef = useRef(null);

    useEffect(() => {
        if (videoRef.current) videoRef.current.playbackRate = 0.8;
    }, []);

    const handleSubmit = async (e) => {
        e.preventDefault();
        setGreska("");
        setLoading(true);
        try {
            const res = await fetch("http://localhost:5050/api/auth/login", {
                method:  "POST",
                headers: { "Content-Type": "application/json" },
                body:    JSON.stringify({ email, lozinka })
            });
            const data = await res.json();
            if (!res.ok) throw new Error(data.greska || "Грешка при пријави.");
            onLogin(data);
        } catch (err) {
            setGreska(err.message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="lp-root">
            <div className="lp-left">
                <video
                    ref={videoRef}
                    className="lp-video"
                    autoPlay loop muted playsInline
                    src={VIDEO_SRC}
                />
            </div>

            <div className="lp-right">
                <div className="lp-top-bar" />
                <div className="lp-corner-tr" />
                <div className="lp-corner-bl" />

                <div className="lp-logo-wrap">
                    <img src={LOGO_SRC} alt="Плесни студио" className="lp-logo-img" />
                    <div className="lp-welcome">Добродошли назад</div>
                </div>

                <div className="lp-sep">
                    <div className="lp-sep-line" />
                    <div className="lp-sep-dia" />
                    <div className="lp-sep-line" />
                </div>

                <form className="lp-form" onSubmit={handleSubmit}>

                    <div className="lp-field">
                        <label className={`lp-label ${fokus === "email" ? "fokus" : ""}`}>
                            Е-пошта
                        </label>
                        <input
                            className="lp-input"
                            type="email"
                            placeholder="ime.prezime@email.com"
                            value={email}
                            onChange={e => setEmail(e.target.value)}
                            onFocus={() => setFokus("email")}
                            onBlur={() => setFokus(null)}
                            required
                        />
                    </div>

                    <div className="lp-field">
                        <label className={`lp-label ${fokus === "lozinka" ? "fokus" : ""}`}>
                            Лозинка
                        </label>
                        <PasswordInput
                            className="lp-input"
                            value={lozinka}
                            onChange={e => setLozinka(e.target.value)}
                            placeholder="••••••••"
                            onFocus={() => setFokus("lozinka")}
                            onBlur={() => setFokus(null)}
                            required
                        />
                    </div>

                    {greska && <div className="lp-greska">{greska}</div>}

                    <button className="lp-btn" type="submit" disabled={loading}>
                        {loading
                            ? "Пријава у току..."
                            : "Пријавите се"
                        }
                    </button>
                </form>

                <div className="lp-foot">Плесни Студио &nbsp;&middot;&nbsp; 2026</div>
            </div>
        </div>
    );
}