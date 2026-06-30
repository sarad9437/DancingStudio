import { useState } from "react";
import DatePicker from "react-datepicker";
import "react-datepicker/dist/react-datepicker.css";
import { formatDate } from "../data/dateUtils";
import srLocale from "../data/srLocale";
import Modal from "../components/Modal";
import NivoBadge from "../components/Badge";
import {
    addUcenica,
    deleteUcenica,
    updateNivo,
    updateUcenica,
    getBrojNastupa,
    dodajUcenicuUGrupu,
    izbaciUcenicuIzGrupe
} from "../data/api";

const PRAZNA_FORMA = {
    ime: "", prezime: "", email: "",
    datumUpisa: "", nivo: "Почетни", grupaId: ""
};

const PRAZNA_FORMA_EDIT = {
    ime: "", prezime: "", email: "",
    datumUpisa: "", nivo: "Почетни"
};

export default function UceniciPage({ ucenici, grupe, korisnik, showToast, reload }) {
    const [search,      setSearch]      = useState("");
    const [showAdd,     setShowAdd]     = useState(false);
    const [showEdit,    setShowEdit]    = useState(null);
    const [showNivo,    setShowNivo]    = useState(null);
    const [noviNivo,    setNoviNivo]    = useState("Почетни");
    const [showBroj,    setShowBroj]    = useState(null);
    const [showDel,     setShowDel]     = useState(null);
    const [showGrupe,   setShowGrupe]   = useState(null); 
    const [novaGrupaId, setNovaGrupaId] = useState("");
    const [loading,     setLoading]     = useState(false);
    const [forma,       setForma]       = useState(PRAZNA_FORMA);
    const [formaEdit,   setFormaEdit]   = useState(PRAZNA_FORMA_EDIT);

    const isAdmin = korisnik?.uloga === "Admin";

    const zatvoriAdd   = () => { setShowAdd(false);   setForma(PRAZNA_FORMA); };
    const zatvoriEdit  = () => { setShowEdit(null);   setFormaEdit(PRAZNA_FORMA_EDIT); };
    const zatvoriNivo  = () => { setShowNivo(null);   setNoviNivo("Почетни"); };
    const zatvoriGrupe = () => { setShowGrupe(null);  setNovaGrupaId(""); };

    const filtered = ucenici
        .filter(u => `${u.osoba.ime} ${u.osoba.prezime}`
            .toLowerCase().includes(search.toLowerCase()))
        .filter((u, idx, arr) =>
            arr.findIndex(x => x.osoba.id === u.osoba.id) === idx
        );

    const handleAdd = async () => {
        if (!forma.ime || !forma.prezime || !forma.email) {
            showToast("Молимо попуните сва обавезна поља.", "error"); return;
        }
        if (!forma.datumUpisa) {
            showToast("Молимо изаберите датум уписа.", "error"); return;
        }
        if (!forma.grupaId) {
            showToast("Молимо изаберите групу.", "error"); return;
        }
        setLoading(true);
        try {
            await addUcenica({
                osoba: { ime: forma.ime, prezime: forma.prezime, email: forma.email },
                datumUpisa: forma.datumUpisa,
                nivo: forma.nivo
            }, parseInt(forma.grupaId));
            showToast("Ученик је успешно додат.", "success");
            zatvoriAdd();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleEdit = async () => {
        if (!formaEdit.ime || !formaEdit.prezime || !formaEdit.email) {
            showToast("Молимо попуните сва обавезна поља.", "error"); return;
        }
        if (!formaEdit.datumUpisa) {
            showToast("Молимо изаберите датум уписа.", "error"); return;
        }
        setLoading(true);
        try {
            await updateUcenica(showEdit.osoba.id, {
                osoba: {
                    id:      showEdit.osoba.id,
                    ime:     formaEdit.ime,
                    prezime: formaEdit.prezime,
                    email:   formaEdit.email
                },
                datumUpisa: formaEdit.datumUpisa,
                nivo:       formaEdit.nivo
            });
            showToast("Ученик је успешно измењен.", "success");
            zatvoriEdit();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleNivo = async () => {
        setLoading(true);
        try {
            await updateNivo(showNivo.osoba.id, noviNivo);
            showToast("Ниво успешно измењен.", "success");
            zatvoriNivo();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleBrojNastupa = async (u) => {
        try {
            const res = await getBrojNastupa(u.osoba.id);
            setShowBroj({ ucenik: u, broj: res.brojNastupa });
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        }
    };

    const handleDodajUGrupu = async () => {
        if (!novaGrupaId) {
            showToast("Молимо изаберите групу.", "error"); return;
        }
        setLoading(true);
        try {
            await dodajUcenicuUGrupu(showGrupe.osoba.id, parseInt(novaGrupaId));
            showToast("Ученик је успешно додат у групу.", "success");
            setNovaGrupaId("");
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleIzbaciIzGrupe = async (grupaId) => {
        setLoading(true);
        try {
            await izbaciUcenicuIzGrupe(showGrupe.osoba.id, grupaId);
            showToast("Ученик је избачен из групе.", "success");
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
            await deleteUcenica(showDel.osoba.id);
            showToast("Ученик је обрисан.", "success");
            setShowDel(null);
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

  
    const getGrupeUcenice = (ucenikId) => {
        return ucenici
            .filter(u => u.osoba.id === ucenikId && u.grupaId)
            .map(u => ({ id: u.grupaId, naziv: u.grupaNaziv }))
            .filter((g, idx, arr) => arr.findIndex(x => x.id === g.id) === idx);
    };

    const slobodneGrupe = (ucenikId) => {
        const upisaneIds = getGrupeUcenice(ucenikId).map(g => g.id);
        return grupe.filter(g => !upisaneIds.includes(g.id));
    };

    return (
        <div>
            <div className="ph">
                <h2>Ученици</h2>
                <p>Управљање ученицима плесног студија · {filtered.length} резултата</p>
            </div>

            <div className="toolbar">
                <div className="sb-search">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                        stroke="currentColor" strokeWidth="2"
                        style={{ color:"var(--ink-muted)", flexShrink:0 }}>
                        <circle cx="11" cy="11" r="8"/>
                        <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                    </svg>
                    <input
                        placeholder="Претрага по имену или презимену..."
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
                        + Додај ученика
                    </button>
                )}
            </div>

            <div className="card">
                {filtered.length === 0 ? (
                    <div className="empty">
                        <p>{search ? `Нема резултата за „${search}"` : "Нема уписаних ученика."}</p>
                    </div>
                ) : (
                    <div className="tw">
                        <table className="table-compact">
                            <thead>
                                <tr>
                                    <th>Ученик</th>
                                    {isAdmin && <th>Е-пошта</th>}
                                    <th>Књижица</th>

                                    {isAdmin && <th>Упис</th>}
                                    <th>Ниво</th>
                                    <th>Акције</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filtered.map(u => (
                                    <tr key={u.osoba.id}>
                                        <td>
                                            <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                                                <div className="rav" style={{ fontSize:11 }}>
                                                    {u.osoba.ime?.[0]}{u.osoba.prezime?.[0]}
                                                </div>
                                                <strong>{u.osoba.ime} {u.osoba.prezime}</strong>
                                            </div>
                                        </td>
                                        {isAdmin && <td>{u.osoba.email}</td>}
                                        <td>
                                            <span style={{ fontFamily:"Montserrat", fontSize:12,
                                                background:"var(--petal)", padding:"2px 7px",
                                                borderRadius:6 }}>
                                                {u.brojKnjizice}
                                            </span>
                                        </td>

                                        {isAdmin && <td>{formatDate(u.datumUpisa)}</td>}
                                        <td><NivoBadge nivo={u.nivo} /></td>
                                        <td>
                                            <div className="acts">
                                                {isAdmin ? (
                                                    <>
                                                        <button
                                                            className="btn btn-s btn-sm"
                                                            onClick={() => {
                                                                setShowEdit(u);
                                                                setFormaEdit({
                                                                    ime:        u.osoba.ime,
                                                                    prezime:    u.osoba.prezime,
                                                                    email:      u.osoba.email,
                                                                    datumUpisa: u.datumUpisa?.slice(0, 10) ?? "",
                                                                    nivo:       u.nivo
                                                                });
                                                            }}
                                                        >
                                                            Измени
                                                        </button>
                                                        <button
                                                            className="btn btn-s btn-sm"
                                                            onClick={() => {
                                                                setShowGrupe(u);
                                                                setNovaGrupaId("");
                                                            }}
                                                        >
                                                            Групе
                                                        </button>
                                                        <button
                                                            className="btn btn-s btn-sm"
                                                            onClick={() => handleBrojNastupa(u)}
                                                        >
                                                            Наступи
                                                        </button>
                                                        <button
                                                            className="btn btn-d btn-sm"
                                                            onClick={() => setShowDel(u)}
                                                        >
                                                            Обриши
                                                        </button>
                                                    </>
                                                ) : (
                                                    <>
                                                        <button
                                                            className="btn btn-s btn-sm"
                                                            onClick={() => { setShowNivo(u); setNoviNivo(u.nivo); }}
                                                            disabled={loading}
                                                        >
                                                            Ниво
                                                        </button>
                                                        <button
                                                            className="btn btn-s btn-sm"
                                                            onClick={() => handleBrojNastupa(u)}
                                                        >
                                                            Наступи
                                                        </button>
                                                    </>
                                                )}
                                            </div>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    </div>
                )}
            </div>

            {showAdd && (
                <Modal
                    title="Додај ученика"
                    onClose={zatvoriAdd}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriAdd}>Откажи</button>
                        <button className="btn btn-p" onClick={handleAdd} disabled={loading}>
                            {loading ? "Чекај..." : "Додај ученика"}
                        </button>
                    </>}
                >
                    <div className="fg">
                        <div>
                            <label>Ime</label>
                            <input
                                value={forma.ime}
                                onChange={e => setForma({ ...forma, ime: e.target.value })}
                                placeholder="нпр. Јелена"
                            />
                        </div>
                        <div>
                            <label>Презиме</label>
                            <input
                                value={forma.prezime}
                                onChange={e => setForma({ ...forma, prezime: e.target.value })}
                                placeholder="нпр. Николић"
                            />
                        </div>
                        <div className="full">
                            <label>Е-пошта</label>
                            <input
                                type="email"
                                value={forma.email}
                                onChange={e => setForma({ ...forma, email: e.target.value })}
                                placeholder="jelena.nikolic@gmail.com"
                            />
                        </div>
                        <div>
                            <label>Датум уписа</label>
                            <DatePicker
                                selected={forma.datumUpisa ? new Date(forma.datumUpisa) : null}
                                onChange={date => setForma({ ...forma,
                                    datumUpisa: date ? `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}` : "" })}
                                dateFormat="dd.MM.yyyy."
                                maxDate={new Date()}
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
                            <label>Ниво</label>
                            <select
                                value={forma.nivo}
                                onChange={e => setForma({ ...forma, nivo: e.target.value })}
                            >
                                <option>Почетни</option>
                                <option>Средњи</option>
                                <option>Напредни</option>
                            </select>
                        </div>
                        <div className="full">
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
                    </div>
                </Modal>
            )}

            {showEdit && (
                <Modal
                    title="Измени ученика"
                    onClose={zatvoriEdit}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriEdit}>Откажи</button>
                        <button className="btn btn-p" onClick={handleEdit} disabled={loading}>
                            {loading ? "Чекај..." : "Сачувај"}
                        </button>
                    </>}
                >
                    <div className="fg">
                        <div>
                            <label>Ime</label>
                            <input
                                value={formaEdit.ime}
                                onChange={e => setFormaEdit({ ...formaEdit, ime: e.target.value })}
                                placeholder="нпр. Јелена"
                            />
                        </div>
                        <div>
                            <label>Презиме</label>
                            <input
                                value={formaEdit.prezime}
                                onChange={e => setFormaEdit({ ...formaEdit, prezime: e.target.value })}
                                placeholder="нпр. Николић"
                            />
                        </div>
                        <div className="full">
                            <label>Е-пошта</label>
                            <input
                                type="email"
                                value={formaEdit.email}
                                onChange={e => setFormaEdit({ ...formaEdit, email: e.target.value })}
                                placeholder="jelena.nikolic@gmail.com"
                            />
                        </div>
                        <div>
                            <label>Датум уписа</label>
                            <DatePicker
                                selected={formaEdit.datumUpisa ? new Date(formaEdit.datumUpisa) : null}
                                onChange={date => setFormaEdit({ ...formaEdit,
                                    datumUpisa: date ? `${date.getFullYear()}-${String(date.getMonth()+1).padStart(2,'0')}-${String(date.getDate()).padStart(2,'0')}` : "" })}
                                dateFormat="dd.MM.yyyy."
                                maxDate={new Date()}
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
                            <label>Ниво</label>
                            <select
                                value={formaEdit.nivo}
                                onChange={e => setFormaEdit({ ...formaEdit, nivo: e.target.value })}
                            >
                                <option>Почетни</option>
                                <option>Средњи</option>
                                <option>Напредни</option>
                            </select>
                        </div>
                    </div>
                </Modal>
            )}

            {showGrupe && (
                <Modal
                    title={`Групе — ${showGrupe.osoba.ime} ${showGrupe.osoba.prezime}`}
                    onClose={zatvoriGrupe}
                    footer={
                        <button className="btn btn-g" onClick={zatvoriGrupe}>Затвори</button>
                    }
                >
                    <div className="fg1">
                        <div style={{ marginBottom: 16 }}>
                            <label style={{ display:"block", marginBottom: 8 }}>
                                Тренутне групе:
                            </label>
                            {getGrupeUcenice(showGrupe.osoba.id).length === 0 ? (
                                <p style={{ fontSize:13, color:"var(--ink-muted)" }}>
                                    Ученик није у ниједној групи.
                                </p>
                            ) : (
                                <ul style={{ listStyle:"none", padding:0, margin:0, display:"flex", flexDirection:"column", gap:8 }}>
                                    {getGrupeUcenice(showGrupe.osoba.id).map(g => (
                                        <li key={g.id} style={{
                                            display:"flex", alignItems:"center",
                                            justifyContent:"space-between",
                                            background:"var(--petal)",
                                            borderRadius:8, padding:"8px 12px"
                                        }}>
                                            <span style={{ fontSize:14, fontWeight:500, color:"#1e1414" }}>
                                                {g.naziv}
                                            </span>
                                            <button
                                                className="btn btn-d btn-sm"
                                                onClick={() => handleIzbaciIzGrupe(g.id)}
                                                disabled={loading}
                                                title="Избаци из групе"
                                            >
                                                Избаци
                                            </button>
                                        </li>
                                    ))}
                                </ul>
                            )}
                        </div>

                        {slobodneGrupe(showGrupe.osoba.id).length > 0 && (
                            <div style={{
                                borderTop:"1px solid rgba(201,168,130,0.2)",
                                paddingTop:16
                            }}>
                                <label style={{ display:"block", marginBottom:8 }}>
                                    Додај у групу:
                                </label>
                                <div style={{ display:"flex", gap:8 }}>
                                    <select
                                        value={novaGrupaId}
                                        onChange={e => setNovaGrupaId(e.target.value)}
                                        style={{ flex:1 }}
                                    >
                                        <option value="">— Изабери групу —</option>
                                        {slobodneGrupe(showGrupe.osoba.id).map(g => (
                                            <option key={g.id} value={g.id}>{g.naziv}</option>
                                        ))}
                                    </select>
                                    <button
                                        className="btn btn-p"
                                        onClick={handleDodajUGrupu}
                                        disabled={loading || !novaGrupaId}
                                    >
                                        {loading ? "Чекај..." : "Додај"}
                                    </button>
                                </div>
                            </div>
                        )}

                        {slobodneGrupe(showGrupe.osoba.id).length === 0 && (
                            <p style={{ fontSize:13, color:"var(--ink-muted)",
                                borderTop:"1px solid rgba(201,168,130,0.2)",
                                paddingTop:16, marginTop:0 }}>
                                Ученик је већ у свим групама.
                            </p>
                        )}
                    </div>
                </Modal>
            )}

            {showNivo && (
                <Modal
                    title="Промени ниво"
                    onClose={zatvoriNivo}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriNivo}>Откажи</button>
                        <button className="btn btn-p" onClick={handleNivo} disabled={loading}>
                            {loading ? "Чекај..." : "Сачувај"}
                        </button>
                    </>}
                >
                    <div className="fg1">
                        <div style={{ display:"flex", alignItems:"center", gap:12,
                            padding:"10px 0", marginBottom:8 }}>
                            <div className="rav">
                                {showNivo.osoba.ime?.[0]}{showNivo.osoba.prezime?.[0]}
                            </div>
                            <div>
                                <div style={{ fontWeight:600, color:"var(--brown)" }}>
                                    {showNivo.osoba.ime} {showNivo.osoba.prezime}
                                </div>
                                <div style={{ fontSize:12, color:"var(--brown-mid)" }}>
                                    Тренутни ниво: {showNivo.nivo}
                                </div>
                            </div>
                        </div>
                        <div>
                            <label>Нови ниво</label>
                            <select value={noviNivo} onChange={e => setNoviNivo(e.target.value)}>
                                <option>Почетни</option>
                                <option>Средњи</option>
                                <option>Напредни</option>
                            </select>
                        </div>
                    </div>
                </Modal>
            )}

            {showBroj && (
                <Modal
                    title="Број наступа"
                    onClose={() => setShowBroj(null)}
                    footer={
                        <button className="btn btn-g" onClick={() => setShowBroj(null)}>Затвори</button>
                    }
                >
                    <div className="bnbox">
                        <div style={{ display:"flex", alignItems:"center", gap:12,
                            justifyContent:"center", marginBottom:16 }}>
                            <div className="rav">
                                {showBroj.ucenik.osoba.ime?.[0]}{showBroj.ucenik.osoba.prezime?.[0]}
                            </div>
                            <span style={{ fontSize:13, color:"var(--ink-soft)", fontWeight:500 }}>
                                {showBroj.ucenik.osoba.ime} {showBroj.ucenik.osoba.prezime}
                            </span>
                        </div>
                        <div className="bnval">{showBroj.broj}</div>
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
                        Да ли сте сигурни да желите да обришете ученика{" "}
                        <span className="chl">{showDel.osoba.ime} {showDel.osoba.prezime}</span>?
                        Биће обрисана и сва његова задужења.
                    </p>
                </Modal>
            )}
        </div>
    );
}