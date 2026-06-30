import { useState } from "react";
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import { formatDate } from "../data/dateUtils";
import srLocale from "../data/srLocale";
import Modal from "../components/Modal";
import { addNastup, updateNastup, deleteNastup } from "../data/api";

const PRAZNA_FORMA = { naziv: "", datum: "", lokacija: "", grupaId: "", instruktorId: "" };

export default function NastupiPage({ nastupi, grupe, instruktori, korisnik, showToast, reload }) {
    const [search,   setSearch]   = useState("");
    const [showAdd,  setShowAdd]  = useState(false);
    const [showEdit, setShowEdit] = useState(null);
    const [showDel,  setShowDel]  = useState(null);
    const [loading,  setLoading]  = useState(false);
    const [forma,    setForma]    = useState(PRAZNA_FORMA);

    const isAdmin      = korisnik?.uloga === "Admin";
    const instruktorId = korisnik?.instruktorId;

    const zatvoriAdd  = () => { setShowAdd(false); setForma(PRAZNA_FORMA); };
    const zatvoriEdit = () => { setShowEdit(null); setForma(PRAZNA_FORMA); };

    const vidljiviNastupi = isAdmin
        ? nastupi
        : nastupi.filter(n =>
            grupe.some(g =>
                g.id === n.grupa?.id &&
                (g.koreograf?.osoba?.id === instruktorId ||
                 g.predavac?.osoba?.id  === instruktorId)
            )
        );

    const filtered = vidljiviNastupi.filter(n =>
        `${n.naziv} ${n.lokacija}`.toLowerCase().includes(search.toLowerCase())
    );

    const handleAdd = async () => {
        if (!forma.naziv) {
            showToast("Молимо унесите назив наступа.", "error"); return;
        }
        if (!forma.datum) {
            showToast("Молимо изаберите датум наступа.", "error"); return;
        }
        if (!forma.lokacija) {
            showToast("Молимо унесите локацију наступа.", "error"); return;
        }
        if (!forma.grupaId) {
            showToast("Молимо изаберите групу.", "error"); return;
        }
        if (!forma.instruktorId) {
            showToast("Молимо изаберите организатора.", "error"); return;
        }
        setLoading(true);
        try {
            await addNastup({
                naziv:       forma.naziv,
                datum:       forma.datum,
                lokacija:    forma.lokacija,
                grupa:       { id: parseInt(forma.grupaId) },
                organizator: { osoba: { id: parseInt(forma.instruktorId) } }
            });
            showToast("Наступ успешно додат.", "success");
            zatvoriAdd();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleEdit = async () => {
        if (!forma.naziv) {
            showToast("Молимо унесите назив наступа.", "error"); return;
        }
        if (!forma.datum) {
            showToast("Молимо изаберите датум наступа.", "error"); return;
        }
        if (!forma.lokacija) {
            showToast("Молимо унесите локацију наступа.", "error"); return;
        }
        if (!forma.grupaId) {
            showToast("Молимо изаберите групу.", "error"); return;
        }
        if (!forma.instruktorId) {
            showToast("Молимо изаберите организатора.", "error"); return;
        }
        setLoading(true);
        try {
            await updateNastup(showEdit.id, {
                naziv:       forma.naziv,
                datum:       forma.datum,
                lokacija:    forma.lokacija,
                grupa:       { id: parseInt(forma.grupaId) },
                organizator: { osoba: { id: parseInt(forma.instruktorId) } }
            });
            showToast("Наступ успешно измењен.", "success");
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
            await deleteNastup(showDel.id);
            showToast("Наступ успешно обрисан.", "success");
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
                <label>Назив наступа</label>
                <input
                    value={forma.naziv}
                    onChange={e => setForma({ ...forma, naziv: e.target.value })}
                    placeholder="нпр. Пролећни концерт 2026"
                />
            </div>
            <div>
                <label>Датум</label>
                <DatePicker
                    selected={forma.datum ? new Date(forma.datum) : null}
                    onChange={date => setForma({ ...forma,
                        datum: date ? `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}` : "" })}
                    dateFormat="dd.MM.yyyy."
                    minDate={new Date()}
                    placeholderText="dd.mm.yyyy."
                    locale={srLocale}
                    className="dp-input"
                    calendarClassName="dp-cal"
                    showMonthDropdown
                    showYearDropdown
                    dropdownMode="select"
                    popperPlacement="bottom-start"
                    popperProps={{ strategy: "fixed" }}
                />
            </div>
            <div>
                <label>Локација</label>
                <input
                    value={forma.lokacija}
                    onChange={e => setForma({ ...forma, lokacija: e.target.value })}
                    placeholder="нпр. Дом омладине Београд"
                />
            </div>
            <div>
                <label>Група</label>
                <select
                    value={forma.grupaId}
                    onChange={e => setForma({ ...forma, grupaId: e.target.value })}
                >
                    <option value="">— Изабери групу —</option>
                    {grupe.map(g => (
                        <option key={g.id} value={g.id}>{g.naziv}</option>
                    ))}
                </select>
            </div>
            <div>
                <label>Организатор</label>
                <select
                    value={forma.instruktorId}
                    onChange={e => setForma({ ...forma, instruktorId: e.target.value })}
                >
                    <option value="">— Изабери инструктора —</option>
                    {instruktori.map(i => (
                        <option key={i.osoba.id} value={i.osoba.id}>
                            {i.osoba.ime} {i.osoba.prezime}
                        </option>
                    ))}
                </select>
            </div>
        </div>
    );

    return (
        <div>
            <div className="ph">
                <h2>Наступи</h2>
                <p>
                    {isAdmin
                        ? `Преглед и управљање наступима · ${filtered.length} резултата`
                        : `Наступи мојих група · ${filtered.length} резултата`}
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
                        placeholder="Претрага по називу или локацији..."
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
                        + Додај наступ
                    </button>
                )}
            </div>

            <div className="card">
                {filtered.length === 0 ? (
                    <div className="empty">
                        <p>{search
                            ? `Нема резултата за „${search}"`
                            : isAdmin
                                ? "Нема наступа."
                                : "Нема наступа за ваше групе."
                        }</p>
                    </div>
                ) : (
                    <div className="tw">
                        <table>
                            <thead>
                                <tr>
                                    <th>Назив наступа</th>
                                    <th>Датум</th>
                                    <th>Локација</th>
                                    <th>Група</th>
                                    <th>Организатор</th>
                                    {isAdmin && <th>Акције</th>}
                                </tr>
                            </thead>
                            <tbody>
                                {filtered.map(n => (
                                    <tr key={n.id}>
                                        <td><strong>{n.naziv}</strong></td>
                                        <td>
                                            <span style={{ fontFamily:"Montserrat", fontSize:12,
                                                background:"var(--petal)", color:"#1e1414",
                                                padding:"2px 7px", borderRadius:6 }}>
                                                {formatDate(n.datum)}
                                            </span>
                                        </td>
                                        <td>{n.lokacija}</td>
                                        <td>{n.grupa?.naziv}</td>
                                        <td>
                                            <div style={{ display:"flex", alignItems:"center", gap:8 }}>
                                                <div className="rav" style={{ fontSize:11 }}>
                                                    {n.organizator?.osoba?.ime?.[0]}
                                                    {n.organizator?.osoba?.prezime?.[0]}
                                                </div>
                                                {n.organizator?.osoba?.ime} {n.organizator?.osoba?.prezime}
                                            </div>
                                        </td>
                                        {isAdmin && (
                                            <td>
                                                <div className="acts">
                                                    <button
                                                        className="btn btn-s btn-sm"
                                                        onClick={() => {
                                                            setShowEdit(n);
                                                            setForma({
                                                                naziv:        n.naziv,
                                                                datum:        n.datum?.slice(0, 10) ?? "",
                                                                lokacija:     n.lokacija,
                                                                grupaId:      n.grupa?.id ?? "",
                                                                instruktorId: n.organizator?.osoba?.id ?? ""
                                                            });
                                                        }}
                                                    >
                                                        Измени
                                                    </button>
                                                    <button
                                                        className="btn btn-d btn-sm"
                                                        onClick={() => setShowDel(n)}
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
                    title="Додај наступ"
                    onClose={zatvoriAdd}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriAdd}>Откажи</button>
                        <button className="btn btn-p" onClick={handleAdd} disabled={loading}>
                            {loading ? "Чекај..." : "Додај наступ"}
                        </button>
                    </>}
                >
                    {formaJSX}
                </Modal>
            )}

            {isAdmin && showEdit && (
                <Modal
                    title="Измени наступ"
                    onClose={zatvoriEdit}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriEdit}>Откажи</button>
                        <button className="btn btn-p" onClick={handleEdit} disabled={loading}>
                            {loading ? "Чекај..." : "Сачувај"}
                        </button>
                    </>}
                >
                    {formaJSX}
                </Modal>
            )}

            {isAdmin && showDel && (
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
                        Да ли сте сигурни да желите да обришете наступ{" "}
                        <span className="chl">{showDel.naziv}</span>?
                        Брисање неће бити могуће ако постоје задужења везана за њега.
                    </p>
                </Modal>
            )}
        </div>
    );
}