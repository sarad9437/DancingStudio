import { useState } from "react";
import Modal from "../components/Modal";
import { addGrupa, updateGrupa, deleteGrupa } from "../data/api";

const PRAZNA_FORMA = { naziv: "", kursId: "", koreografId: "", predavacId: "" };

export default function GrupePage({ grupe, instruktori, kursevi, showToast, reload }) {
    const [search,   setSearch]   = useState("");
    const [showAdd,  setShowAdd]  = useState(false);
    const [showEdit, setShowEdit] = useState(null);
    const [showDel,  setShowDel]  = useState(null);
    const [loading,  setLoading]  = useState(false);
    const [forma,    setForma]    = useState(PRAZNA_FORMA);

    const zatvoriAdd  = () => { setShowAdd(false); setForma(PRAZNA_FORMA); };
    const zatvoriEdit = () => { setShowEdit(null); setForma(PRAZNA_FORMA); };

    const filtered = grupe.filter(g =>
        g.naziv?.toLowerCase().includes(search.toLowerCase())
    );

    const handleAdd = async () => {
        if (!forma.naziv || !forma.kursId || !forma.koreografId || !forma.predavacId) {
            showToast("Молимо попуните сва поља.", "error");
            return;
        }
        setLoading(true);
        try {
            await addGrupa({
                naziv:     forma.naziv,
                kurs:      { id: parseInt(forma.kursId) },
                koreograf: { osoba: { id: parseInt(forma.koreografId) } },
                predavac:  { osoba: { id: parseInt(forma.predavacId) } }
            });
            showToast("Група успешно додата.", "success");
            zatvoriAdd();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleEdit = async () => {
        if (!forma.naziv || !forma.kursId || !forma.koreografId || !forma.predavacId) {
            showToast("Молимо попуните сва поља.", "error");
            return;
        }
        setLoading(true);
        try {
            await updateGrupa(showEdit.id, {
                naziv:     forma.naziv,
                kurs:      { id: parseInt(forma.kursId) },
                koreograf: { osoba: { id: parseInt(forma.koreografId) } },
                predavac:  { osoba: { id: parseInt(forma.predavacId) } }
            });
            showToast("Група успешно измењена.", "success");
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
            await deleteGrupa(showDel.id);
            showToast("Група успешно обрисана.", "success");
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
                <label>Назив групе</label>
                <input
                    value={forma.naziv}
                    onChange={e => setForma({ ...forma, naziv: e.target.value })}
                    placeholder="нпр. Балет група Ц"
                />
            </div>
            <div className="full">
                <label>Курс</label>
                <select
                    value={forma.kursId}
                    onChange={e => setForma({ ...forma, kursId: e.target.value })}
                >
                    <option value="">— Изабери курс —</option>
                    {kursevi.map(k => (
                        <option key={k.id} value={k.id}>{k.naziv}</option>
                    ))}
                </select>
            </div>
            <div>
                <label>Кореограф</label>
                <select
                    value={forma.koreografId}
                    onChange={e => setForma({ ...forma, koreografId: e.target.value })}
                >
                    <option value="">— Изабери кореографа —</option>
                    {instruktori.map(i => (
                        <option key={i.osoba.id} value={i.osoba.id}>
                            {i.osoba.ime} {i.osoba.prezime}
                        </option>
                    ))}
                </select>
            </div>
            <div>
                <label>Предавач</label>
                <select
                    value={forma.predavacId}
                    onChange={e => setForma({ ...forma, predavacId: e.target.value })}
                >
                    <option value="">— Изабери предавача —</option>
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
                <h2>Групе</h2>
                <p>Управљање групама плесног студија · {filtered.length} резултата</p>
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
                        placeholder="Претрага по називу групе..."
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
                <button className="btn btn-p" onClick={() => setShowAdd(true)}>
                    + Додај групу
                </button>
            </div>

            <div className="card">
                {filtered.length === 0 ? (
                    <div className="empty">
                        <p>{search ? `Нема резултата за „${search}"` : "Нема група."}</p>
                    </div>
                ) : (
                    <div className="tw">
                        <table>
                            <thead>
                                <tr>
                                    <th>Назив групе</th>
                                    <th>Курс</th>
                                    <th>Кореограф</th>
                                    <th>Предавач</th>
                                    <th>Ученика</th>
                                    <th>Акције</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filtered.map(g => (
                                    <tr key={g.id}>
                                        <td>
                                            <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                                                <div className="rav" style={{ fontSize:11 }}>
                                                    {g.naziv?.[0]}
                                                </div>
                                                <strong>{g.naziv}</strong>
                                            </div>
                                        </td>
                                        <td>{g.kurs?.naziv}</td>
                                        <td>{g.koreograf?.osoba?.ime} {g.koreograf?.osoba?.prezime}</td>
                                        <td>{g.predavac?.osoba?.ime} {g.predavac?.osoba?.prezime}</td>
                                        <td>
                                            <span style={{ fontFamily:"Montserrat", fontSize:12,
                                                background:"var(--petal)", color:"#1e1414",
                                                padding:"2px 7px", borderRadius:6 }}>
                                                {g.ukupnoUcenika}
                                            </span>
                                        </td>
                                        <td>
                                            <div className="acts">
                                                <button
                                                    className="btn btn-s btn-sm"
                                                    onClick={() => {
                                                        setShowEdit(g);
                                                        setForma({
                                                            naziv:       g.naziv,
                                                            kursId:      g.kurs?.id ?? "",
                                                            koreografId: g.koreograf?.osoba?.id ?? "",
                                                            predavacId:  g.predavac?.osoba?.id ?? ""
                                                        });
                                                    }}
                                                >
                                                    Измени
                                                </button>
                                                <button
                                                    className="btn btn-d btn-sm"
                                                    onClick={() => setShowDel(g)}
                                                    disabled={g.ukupnoUcenika > 0}
                                                    title={g.ukupnoUcenika > 0
                                                        ? "Не може се обрисати – група има ученике"
                                                        : "Обриши"}
                                                >
                                                    Обриши
                                                </button>
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
                    title="Додај групу"
                    onClose={zatvoriAdd}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriAdd}>Откажи</button>
                        <button className="btn btn-p" onClick={handleAdd} disabled={loading}>
                            {loading ? "Чекај..." : "Додај групу"}
                        </button>
                    </>}
                >
                    {formaJSX}
                </Modal>
            )}

            {showEdit && (
                <Modal
                    title="Измени групу"
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
                        Да ли сте сигурни да желите да обришете групу{" "}
                        <span className="chl">{showDel.naziv}</span>?
                        Брисање неће бити могуће ако постоје наступи везани за њу.
                    </p>
                </Modal>
            )}
        </div>
    );
}