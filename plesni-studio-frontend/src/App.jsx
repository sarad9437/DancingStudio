import { useState, useEffect, useCallback } from "react";
import LoginPage from "./pages/LoginPage";
import Dashboard from "./pages/Dashboard";
import UceniciPage from "./pages/UceniciPage";
import InstruktoriPage from "./pages/InstruktoriPage";
import GrupePage from "./pages/GrupePage";
import NastupiPage from "./pages/NastupiPage";
import ZaduzenjaPage from "./pages/ZaduzenjaPage";
import KostimiPage from "./pages/KostimiPage";
import KurseviPage from "./pages/KurseviPage";
import Toast from "./components/Toast";
import Confetti from "./components/Confetti";
import Reflektori from "./components/Reflektori";
import Modal from "./components/Modal";
import PasswordInput from "./components/PasswordInput";
import {
    getUcenici, getInstruktori, getGrupe,
    getNastupi, getKostimi, getKursevi, getZaduzenja
} from "./data/api";

export default function App() {

    const [korisnik, setKorisnik] = useState(() => {
        try {
            const s = sessionStorage.getItem("ps_korisnik");
            return s ? JSON.parse(s) : null;
        } catch { return null; }
    });

    const handleLogin  = (data) => { sessionStorage.setItem("ps_korisnik", JSON.stringify(data)); setKorisnik(data); };
    const handleLogout = () => { sessionStorage.removeItem("ps_korisnik"); setKorisnik(null); };
    const isAdmin = korisnik?.uloga === "Admin";

    const [page,       setPage]       = useState("dashboard");
    const [toasts,     setToasts]     = useState([]);
    const [showProfil, setShowProfil] = useState(false);
    const [darkMode,   setDarkMode]   = useState(false);

    const showToast   = (msg, type = "info") => setToasts(p => [...p, { id: Date.now(), msg, type }]);
    const removeToast = (id) => setToasts(p => p.filter(t => t.id !== id));

    const [profilForma,   setProfilForma]   = useState({ ime: "", prezime: "", email: "", lozinka: "", lozinka2: "" });
    const [profilLoading, setProfilLoading] = useState(false);

    useEffect(() => {
        if (showProfil && korisnik) {
            setProfilForma({ ime: korisnik.ime ?? "", prezime: korisnik.prezime ?? "", email: korisnik.email ?? "", lozinka: "", lozinka2: "" });
        }
    }, [showProfil, korisnik]);

const handleProfilSave = async () => {
    if (profilForma.lozinka && profilForma.lozinka !== profilForma.lozinka2) {
        showToast("Лозинке се не поклапају.", "error"); return;
    }

    if (!isAdmin) {
        const velikaCirilica = /^[АБВГДЂЕЖЗИЈКЛЉМНЊОПРСТЋУФХЦЧЏШ]/;
        if (profilForma.ime && !velikaCirilica.test(profilForma.ime)) {
            showToast("Име мора започети великим словом ћирилице.", "error"); return;
        }
        if (profilForma.prezime && !velikaCirilica.test(profilForma.prezime)) {
            showToast("Презиме мора започети великим словом ћирилице.", "error"); return;
        }
    }
        setProfilLoading(true);
        try {
            const body = { ime: profilForma.ime, prezime: profilForma.prezime, email: profilForma.email, ...(profilForma.lozinka ? { novaLozinka: profilForma.lozinka } : {}) };
            const res  = await fetch("http://localhost:5050/api/auth/profil", { method: "PUT", headers: { "Content-Type": "application/json", "Authorization": `Bearer ${korisnik?.token}` }, body: JSON.stringify(body) });
            const data = await res.json();
            if (!res.ok) throw new Error(data.greska || "Грешка.");
            const updated = { ...korisnik, ime: profilForma.ime, prezime: profilForma.prezime, email: profilForma.email };
            sessionStorage.setItem("ps_korisnik", JSON.stringify(updated));
            setKorisnik(updated);
            showToast("Профил је успешно ажуриран.", "success");
            setShowProfil(false);
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setProfilLoading(false);
        }
    };

    const [ucenici,     setUcenici]     = useState([]);
    const [instruktori, setInstruktori] = useState([]);
    const [grupe,       setGrupe]       = useState([]);
    const [nastupi,     setNastupi]     = useState([]);
    const [kostimi,     setKostimi]     = useState([]);
    const [kursevi,     setKursevi]     = useState([]);
    const [zaduzenja,   setZaduzenja]   = useState([]);
    const [loading,     setLoading]     = useState(false);

    const loadAll = useCallback(async (priLogin = false) => {
        if (!korisnik) return;
        setLoading(true);
        if (priLogin) await new Promise(r => setTimeout(r, 1500));
        try {
            const rezultati = await Promise.all([
                getUcenici(),
                isAdmin ? getInstruktori() : Promise.resolve([]),
                getGrupe(),
                getNastupi(),
                getKostimi(),
                isAdmin ? getKursevi() : Promise.resolve([]),
                getZaduzenja(),
            ]);

            setUcenici(rezultati[0]);
            setInstruktori(rezultati[1]);
            setGrupe(rezultati[2]);
            setNastupi(rezultati[3]);
            setKostimi(rezultati[4]);
            setKursevi(rezultati[5]);
            setZaduzenja(rezultati[6]);
        } catch (err) {
            if (err.message?.includes("401") || err.message?.includes("403")) handleLogout();
            else showToast("Грешка при учитавању: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    }, [korisnik]);

    useEffect(() => { loadAll(true); }, [loadAll]);

    if (!korisnik) return <LoginPage onLogin={handleLogin} />;
    if (loading) return (
        <div className="loading-screen">
            <img src="/spinning-dancer-anim.png" alt="Учитавање..." style={{ height: 180, width: "auto", opacity: 0.85 }} />
            <div className="loading-text">Учитавање...</div>
        </div>
    );

    const navLinks = [
        { id: "dashboard", label: "Почетна" },
        { id: "ucenici",   label: "Ученици" },
        ...(isAdmin ? [
            { id: "instruktori", label: "Инструктори" },
            { id: "grupe",       label: "Групе" },
        ] : []),
        { id: "nastupi",   label: "Наступи" },
        { id: "zaduzenja", label: "Задужења" },
        ...(isAdmin ? [
            { id: "kostimi", label: "Костими" },
            { id: "kursevi", label: "Курсеви" },
        ] : []),
    ];

    const initials    = isAdmin ? "PS" : `${korisnik.ime?.[0] ?? ""}${korisnik.prezime?.[0] ?? ""}`.toUpperCase();
    const displayName = isAdmin ? "Администратор" : `${korisnik.ime ?? ""} ${korisnik.prezime ?? ""}`.trim();

    return (
        <div className={`shell${darkMode ? " dark" : ""}`}>
            <Confetti />

            <nav className="topnav">
                <Reflektori darkMode={darkMode} onToggle={() => setDarkMode(d => !d)} />
                <div className="tn-brand" onClick={() => setPage("dashboard")} title="Почетна">
                </div>

                <div className="tn-links">
                    {navLinks.map(link => (
                        <button key={link.id} className={`tn-link ${page === link.id ? "active" : ""}`} onClick={() => setPage(link.id)}>
                            {link.label}
                        </button>
                    ))}
                </div>

                <div className="tn-right">
                    <button className="tn-avatar-btn" onClick={() => setShowProfil(true)} title="Уреди профил">
                        <div className="tn-avatar">{initials}</div>
                        <span className="tn-username">{displayName}</span>
                    </button>
                    <div className="tn-sep" />
                    <button className="tn-logout" onClick={handleLogout}>Одјава</button>
                </div>
            </nav>

            <main className="main">
                {page === "dashboard" && <Dashboard ucenici={ucenici} instruktori={instruktori} grupe={grupe} nastupi={nastupi} zaduzenja={zaduzenja} kostimi={kostimi} kursevi={kursevi} korisnik={korisnik} />}
                {page === "ucenici"     && <UceniciPage  ucenici={ucenici} grupe={grupe} korisnik={korisnik} showToast={showToast} reload={loadAll} />}
                {page === "instruktori" && isAdmin && <InstruktoriPage instruktori={instruktori} grupe={grupe} showToast={showToast} reload={loadAll} />}
                {page === "grupe"       && isAdmin && <GrupePage grupe={grupe} instruktori={instruktori} kursevi={kursevi} showToast={showToast} reload={loadAll} />}
                {page === "nastupi"     && <NastupiPage nastupi={nastupi} grupe={grupe} instruktori={instruktori} korisnik={korisnik} showToast={showToast} reload={loadAll} />}
                {page === "zaduzenja" && <ZaduzenjaPage zaduzenja={zaduzenja} ucenici={ucenici} nastupi={nastupi} kostimi={kostimi} grupe={grupe} korisnik={korisnik} showToast={showToast} reload={loadAll} />}                {page === "kostimi"     && isAdmin && <KostimiPage kostimi={kostimi} showToast={showToast} reload={loadAll} />}
                {page === "kursevi"     && isAdmin && <KurseviPage kursevi={kursevi} showToast={showToast} reload={loadAll} />}
            </main>

            {showProfil && (
                <Modal title="Мој профил" onClose={() => setShowProfil(false)}
                    footer={<>
                        <button className="btn btn-g" onClick={() => setShowProfil(false)}>Откажи</button>
                        <button className="btn btn-p" onClick={handleProfilSave} disabled={profilLoading}>
                            {profilLoading ? "Чекај..." : "Сачувај"}
                        </button>
                    </>}
                >
                    <div style={{ display:"flex", alignItems:"center", gap:16, padding:"14px 0 22px", borderBottom:"1px solid var(--border)", marginBottom:22 }}>
                        <div style={{ width:52, height:52, borderRadius:"50%", background:"linear-gradient(135deg, #e8788a, #c95a70)", display:"flex", alignItems:"center", justifyContent:"center", fontSize:18, fontWeight:600, color:"#ffffff", fontFamily:"var(--font-body)", letterSpacing:"0.04em", flexShrink:0 }}>
                            {initials}
                        </div>
                        <div>
                            <div style={{ fontWeight:500, color:"var(--brown)", fontSize:14 }}>{displayName}</div>
                            {!isAdmin && <div style={{ fontSize:11, color:"var(--brown-light)", marginTop:2, letterSpacing:"0.08em" }}>{korisnik.uloga}</div>}
                        </div>
                    </div>

                    <div className="fg">
                        {!isAdmin && (<>
                            <div>
                                <label>Ime</label>
                                <input value={profilForma.ime} onChange={e => setProfilForma({...profilForma, ime: e.target.value})} placeholder="Ваше име" />
                            </div>
                            <div>
                                <label>Презиме</label>
                                <input value={profilForma.prezime} onChange={e => setProfilForma({...profilForma, prezime: e.target.value})} placeholder="Ваше презиме" />
                            </div>
                        </>)}

                        <div className="full">
                            <label>Е-пошта</label>
                            <input type="email" value={profilForma.email} onChange={e => setProfilForma({...profilForma, email: e.target.value})} placeholder="vase@email.com" />
                        </div>

                        <div style={{ gridColumn:"1 / -1", height:1, background:"var(--border)", margin:"4px 0" }} />

                        <div>
                            <label>Нова лозинка</label>
                            <PasswordInput
                                value={profilForma.lozinka}
                                onChange={e => setProfilForma({...profilForma, lozinka: e.target.value})}
                                placeholder="Унесите нову лозинку"
                            />
                        </div>
                        <div>
                            <label>Потврди лозинку</label>
                            <PasswordInput
                                value={profilForma.lozinka2}
                                onChange={e => setProfilForma({...profilForma, lozinka2: e.target.value})}
                                placeholder="Поновите лозинку"
                            />
                        </div>
                    </div>
                </Modal>
            )}

            <Toast toasts={toasts} removeToast={removeToast} />
        </div>
    );
}