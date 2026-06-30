import { useState } from "react";
import { formatDate } from "../data/dateUtils";
import Modal from "../components/Modal";
import { addZaduzenje, updateZaduzenje, deleteZaduzenje } from "../data/api";

const PRAZNA_FORMA = { ucenikId: "", nastupId: "", kostimId: "" };

const VelicinaBadge = ({ velicina }) => (
    <span style={{
        background: "#fce8ea", color: "#c95a70", border: "1px solid #f0a0b0",
        fontSize: 11, fontWeight: 600, padding: "2px 9px",
        borderRadius: 99, display: "inline-block", letterSpacing: "0.2px"
    }}>
        {velicina}
    </span>
);

export default function ZaduzenjaPage({ zaduzenja, ucenici, nastupi, kostimi: kostimiProp, grupe, korisnik, showToast, reload }) {
    const [search,       setSearch]       = useState("");
    const [showAdd,      setShowAdd]      = useState(false);
    const [showEdit,     setShowEdit]     = useState(null);
    const [showDel,      setShowDel]      = useState(null);
    const [loading,      setLoading]      = useState(false);
    const [forma,        setForma]        = useState(PRAZNA_FORMA);
    const [noviKostimId, setNoviKostimId] = useState("");

    const isAdmin = korisnik?.uloga === "Admin";

    const vidljivaZaduzenja = isAdmin
        ? zaduzenja
        : zaduzenja.filter(z =>
            ucenici.some(u => u.osoba.id === z.ucenikId)
        );

    const filtered = vidljivaZaduzenja.filter(z =>
        `${z.ucenikIme} ${z.ucenikPrezime} ${z.nastupNaziv} ${z.kostimNaziv}`
            .toLowerCase().includes(search.toLowerCase())
    );

    const zatvoriAdd  = () => { setShowAdd(false);  setForma(PRAZNA_FORMA); };
    const zatvoriEdit = () => { setShowEdit(null);  setNoviKostimId(""); };

    const uceniceZaNastup = (nastupId) => {
        if (!nastupId) return [];
        const nastup = nastupi.find(n => n.id === parseInt(nastupId));
        if (!nastup) return [];
        const grupaId = nastup.grupa?.id;
        if (!grupaId) return [];
        return ucenici
            .filter(u => u.grupaId === grupaId)
            .filter((u, idx, arr) =>
                arr.findIndex(x => x.osoba.id === u.osoba.id) === idx
            );
    };

    const danas = () => {
        const d = new Date();
        return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
    };

    const handleAdd = async () => {
        if (!forma.ucenikId) {
            showToast("Молимо изаберите ученика.", "error"); return;
        }
        if (!forma.nastupId) {
            showToast("Молимо изаберите наступ.", "error"); return;
        }
        if (!forma.kostimId) {
            showToast("Молимо изаберите костим.", "error"); return;
        }
        setLoading(true);
        try {
            await addZaduzenje({
                ucenik:         { osoba: { id: parseInt(forma.ucenikId) } },
                nastup:         { id: parseInt(forma.nastupId) },
                kostim:         { id: parseInt(forma.kostimId) },
                datumZaduzenja: danas()
            });
            showToast("Задужење успешно додато.", "success");
            zatvoriAdd();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleEdit = async () => {
        if (!noviKostimId) {
            showToast("Молимо изаберите костим.", "error"); return;
        }
        setLoading(true);
        try {
            await updateZaduzenje({
                ucenikId:     showEdit.ucenikId,
                nastupId:     showEdit.nastupId,
                noviKostimId: parseInt(noviKostimId)
            });
            showToast("Задужење успешно измењено.", "success");
            zatvoriEdit();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async () => {
        setLoading(true);
        try {
            await deleteZaduzenje({
                ucenikId: showDel.ucenikId,
                nastupId: showDel.nastupId
            });
            showToast("Задужење успешно обрисано.", "success");
            setShowDel(null);
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const formaJSX = (
        <div className="fg">
            <div className="full">
                <label>Наступ</label>
                <select
                    value={forma.nastupId}
                    onChange={e => setForma({ ...forma, nastupId: e.target.value, ucenikId: "" })}
                >
                    <option value="">— Изабери наступ —</option>
                    {nastupi.map(n => (
                        <option key={n.id} value={n.id}>
                            {n.naziv} — {formatDate(n.datum)}
                        </option>
                    ))}
                </select>
            </div>
            <div className="full">
                <label>Ученик</label>
                <select
                    value={forma.ucenikId}
                    onChange={e => setForma({ ...forma, ucenikId: e.target.value })}
                    disabled={!forma.nastupId}
                >
                    <option value="">
                        {forma.nastupId
                            ? "— Изабери ученика —"
                            : "— Прво изабери наступ —"}
                    </option>
                    {uceniceZaNastup(forma.nastupId).map(u => (
                        <option key={u.osoba.id} value={u.osoba.id}>
                            {u.osoba.ime} {u.osoba.prezime}
                        </option>
                    ))}
                </select>
            </div>
            <div className="full">
                <label>Костим</label>
                <select
                    value={forma.kostimId}
                    onChange={e => setForma({ ...forma, kostimId: e.target.value })}
                >
                    <option value="">— Изабери костим —</option>
                    {kostimiProp.map(k => (
                        <option key={k.id} value={k.id}>
                            {k.naziv} ({k.velicina}, {k.boja})
                        </option>
                    ))}
                </select>
            </div>
        </div>
    );

    return (
        <div>
            <div className="ph">
                <h2>Задужења</h2>
                <p>
                    {isAdmin
                        ? `Додела костима ученицима за наступе · ${filtered.length} резултата`
                        : `Задужења мојих ученика · ${filtered.length} резултата`}
                </p>
            </div>

            <div className="toolbar">
                <div className="sb-search">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" strokeWidth="2"
                        style={{ color: "var(--ink-muted)", flexShrink: 0 }}>
                        <circle cx="11" cy="11" r="8"/>
                        <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                    </svg>
                    <input
                        placeholder="Претрага по ученику, наступу или костиму..."
                        value={search}
                        onChange={e => setSearch(e.target.value)}
                    />
                    {search && (
                        <button onClick={() => setSearch("")}
                            style={{ background:"none", border:"none", cursor:"pointer",
                                color:"var(--ink-muted)", padding:0, fontSize:14, lineHeight:1 }}>
                            ✕
                        </button>
                    )}
                </div>
                {isAdmin && (
                    <button className="btn btn-p" onClick={() => setShowAdd(true)}>
                        + Додај задужење
                    </button>
                )}
            </div>

            <div className="card">
                {filtered.length === 0 ? (
                    <div className="empty">
                        <p>
                            {search
                                ? `Нема резултата за „${search}"`
                                : isAdmin
                                    ? "Нема задужења."
                                    : "Нема задужења за ваше ученике."}
                        </p>
                    </div>
                ) : (
                    <div className="tw">
                        <table>
                            <thead>
                                <tr>
                                    <th>Ученик</th>
                                    <th>Наступ</th>
                                    <th>Датум наступа</th>
                                    <th>Костим</th>
                                    <th>Величина</th>
                                    <th>Боја</th>
                                    <th>Датум задужења</th>
                                    {isAdmin && <th>Акције</th>}
                                </tr>
                            </thead>
                            <tbody>
                                {filtered.map((z, idx) => (
                                    <tr key={idx}>
                                        <td>
                                            <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                                                <div className="rav" style={{ fontSize:11 }}>
                                                    {z.ucenikIme?.[0]}{z.ucenikPrezime?.[0]}
                                                </div>
                                                <strong>{z.ucenikIme} {z.ucenikPrezime}</strong>
                                            </div>
                                        </td>
                                        <td>{z.nastupNaziv}</td>
                                        <td>
                                            <span style={{ fontFamily:"Montserrat", fontSize:12,
                                                background:"var(--petal)", color:"#1e1414",
                                                padding:"2px 7px", borderRadius:6 }}>
                                                {formatDate(z.nastupDatum)}
                                            </span>
                                        </td>
                                        <td>{z.kostimNaziv}</td>
                                        <td><VelicinaBadge velicina={z.kostimVelicina} /></td>
                                        <td>{z.kostimBoja}</td>
                                        <td style={{ color:"var(--brown-soft)", fontSize:12 }}>
                                            {formatDate(z.datumZaduzenja)}
                                        </td>
                                        {isAdmin && (
                                            <td>
                                                <div className="acts">
                                                    <button
                                                        className="btn btn-s btn-sm"
                                                        onClick={() => {
                                                            setShowEdit(z);
                                                            setNoviKostimId(z.kostimId);
                                                        }}
                                                    >
                                                        Измени
                                                    </button>
                                                    <button
                                                        className="btn btn-d btn-sm"
                                                        onClick={() => setShowDel(z)}
                                                    >
                                                        Обриши
                                                    </button>
                                                </div>
                                            </td>
                                        )}
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {isAdmin && showAdd && (
                <Modal
                    title="Додај задужење"
                    onClose={zatvoriAdd}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriAdd}>Откажи</button>
                        <button className="btn btn-p" onClick={handleAdd} disabled={loading}>
                            {loading ? "Чекај..." : "Додај задужење"}
                        </button>
                    </>}
                >
                    {formaJSX}
                </Modal>
            )}

            {isAdmin && showEdit && (
                <Modal
                    title="Измени задужење"
                    onClose={zatvoriEdit}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriEdit}>Откажи</button>
                        <button className="btn btn-p" onClick={handleEdit} disabled={loading}>
                            {loading ? "Чекај..." : "Сачувај"}
                        </button>
                    </>}
                >
                    <div className="fg">
                        <div style={{ display:"flex", alignItems:"center", gap:12,
                            padding:"10px 0", marginBottom:8 }}>
                            <div className="rav">
                                {showEdit.ucenikIme?.[0]}{showEdit.ucenikPrezime?.[0]}
                            </div>
                            <div>
                                <div style={{ fontWeight:600, color:"var(--brown)" }}>
                                    {showEdit.ucenikIme} {showEdit.ucenikPrezime}
                                </div>
                                <div style={{ fontSize:12, color:"var(--brown-mid)" }}>
                                    {showEdit.nastupNaziv} — {formatDate(showEdit.nastupDatum)}
                                </div>
                            </div>
                        </div>
                        <div className="full">
                            <label>Нови костим</label>
                            <select
                                value={noviKostimId}
                                onChange={e => setNoviKostimId(e.target.value)}
                            >
                                <option value="">— Изабери костим —</option>
                                {kostimiProp.map(k => (
                                    <option key={k.id} value={k.id}>
                                        {k.naziv} ({k.velicina}, {k.boja})
                                    </option>
                                ))}
                            </select>
                        </div>
                    </div>
                </Modal>
            )}

            {showDel && (
                <Modal
                    title="Потврди брисање"
                    onClose={() => setShowDel(null)}
                    footer={<>
                        <button className="btn btn-g" onClick={() => setShowDel(null)}>Откажи</button>
                        <button className="btn btn-d" onClick={handleDelete} disabled={loading}>
                            {loading ? "Чекај..." : "Обриши"}
                        </button>
                    </>}
                >
                    <p className="cmsg">
                        Да ли сте сигурни да желите да обришете задужење ученика{" "}
                        <span className="chl">{showDel.ucenikIme} {showDel.ucenikPrezime}</span>{" "}
                        за наступ{" "}
                        <span className="chl">{showDel.nastupNaziv}</span>?
                    </p>
                </Modal>
            )}
        </div>
    );
}