import { useState } from "react";
import Modal from "../components/Modal";
import { addKurs, updateKurs, deleteKurs } from "../data/api";

const PRAZNA_FORMA = { naziv: "", opis: "", trajanjeMeseci: 6, pretKursId: "" };

export default function KurseviPage({ kursevi, showToast, reload }) {
    const [search,   setSearch]   = useState("");
    const [showAdd,  setShowAdd]  = useState(false);
    const [showEdit, setShowEdit] = useState(null);
    const [showDel,  setShowDel]  = useState(null);
    const [loading,  setLoading]  = useState(false);
    const [forma,    setForma]    = useState(PRAZNA_FORMA);

    const zatvoriAdd  = () => { setShowAdd(false); setForma(PRAZNA_FORMA); };
    const zatvoriEdit = () => { setShowEdit(null); setForma(PRAZNA_FORMA); };

    const filtered = kursevi.filter(k =>
        k.naziv?.toLowerCase().includes(search.toLowerCase())
    );

    const handleAdd = async () => {
        if (!forma.naziv) {
            showToast("Молимо унесите назив курса.", "error");
            return;
        }
        setLoading(true);
        try {
            await addKurs({
                naziv:          forma.naziv,
                opis:           forma.opis || null,
                trajanjeMeseci: parseInt(forma.trajanjeMeseci),
                pretKursId:     forma.pretKursId ? parseInt(forma.pretKursId) : null
            });
            showToast("Курс успешно додат.", "success");
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
            showToast("Молимо унесите назив курса.", "error");
            return;
        }
        if (forma.pretKursId && parseInt(forma.pretKursId) === showEdit.id) {
            showToast("Курс не може бити предуслов самом себи.", "error");
            return;
        }
        setLoading(true);
        try {
            await updateKurs(showEdit.id, {
                naziv:          forma.naziv,
                opis:           forma.opis || null,
                trajanjeMeseci: parseInt(forma.trajanjeMeseci),
                pretKursId:     forma.pretKursId ? parseInt(forma.pretKursId) : null
            });
            showToast("Курс успешно измењен.", "success");
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
            await deleteKurs(showDel.id);
            showToast("Курс успешно обрисан.", "success");
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
                <label>Назив курса</label>
                <input
                    value={forma.naziv}
                    onChange={e => setForma({ ...forma, naziv: e.target.value })}
                    placeholder="нпр. Народни плес почетни"
                />
            </div>
            <div className="full">
                <label>Опис (необавезно)</label>
                <input
                    value={forma.opis}
                    onChange={e => setForma({ ...forma, opis: e.target.value })}
                    placeholder="нпр. Уводни курс народних плесова"
                />
            </div>
            <div>
                <label>Трајање (месеци)</label>
                <input
                    type="number" min="1" max="36"
                    value={forma.trajanjeMeseci}
                    onChange={e => setForma({ ...forma, trajanjeMeseci: e.target.value })}
                />
            </div>
            <div>
                <label>Предуслов (необавезно)</label>
                <select
                    value={forma.pretKursId}
                    onChange={e => setForma({ ...forma, pretKursId: e.target.value })}
                >
                    <option value="">— Без предуслова —</option>
                    {kursevi
                        .filter(k => showEdit ? k.id !== showEdit.id : true)
                        .map(k => (
                            <option key={k.id} value={k.id}>{k.naziv}</option>
                        ))
                    }
                </select>
            </div>
        </div>
    );

    return (
        <div>
            <div className="ph">
                <h2>Курсеви</h2>
                <p>Управљање курсевима плесног студија · {filtered.length} резултата</p>
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
                        placeholder="Претрага по називу курса..."
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
                    + Додај курс
                </button>
            </div>

            <div className="card">
                {filtered.length === 0 ? (
                    <div className="empty">
                        <p>{search ? `Нема резултата за „${search}"` : "Нема курсева."}</p>
                    </div>
                ) : (
                    <div className="tw">
                        <table>
                            <thead>
                                <tr>
                                    <th>Назив курса</th>
                                    <th>Опис</th>
                                    <th>Трајање</th>
                                    <th>Предуслов</th>
                                    <th>Акције</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filtered.map(k => (
                                    <tr key={k.id}>
                                        <td><strong>{k.naziv}</strong></td>
                                        <td style={{ color:"var(--brown-soft)", fontSize:13 }}>
                                            {k.opis ?? "—"}
                                        </td>
                                        <td>
                                            <span style={{ fontFamily:"Montserrat", fontSize:12,
                                                background:"var(--petal)", color:"#1e1414",
                                                padding:"2px 7px", borderRadius:6 }}>
                                                {k.trajanjeMeseci} мес.
                                            </span>
                                        </td>
                                        <td>
                                            {k.pretKursId
                                                ? kursevi.find(p => p.id === k.pretKursId)?.naziv ?? "—"
                                                : "—"}
                                        </td>
                                        <td>
                                            <div className="acts">
                                                <button
                                                    className="btn btn-s btn-sm"
                                                    onClick={() => {
                                                        setShowEdit(k);
                                                        setForma({
                                                            naziv:          k.naziv,
                                                            opis:           k.opis ?? "",
                                                            trajanjeMeseci: k.trajanjeMeseci,
                                                            pretKursId:     k.pretKursId ?? ""
                                                        });
                                                    }}
                                                >
                                                    Измени
                                                </button>
                                                <button
                                                    className="btn btn-d btn-sm"
                                                    onClick={() => setShowDel(k)}
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
                    title="Додај курс"
                    onClose={zatvoriAdd}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriAdd}>Откажи</button>
                        <button className="btn btn-p" onClick={handleAdd} disabled={loading}>
                            {loading ? "Чекај..." : "Додај курс"}
                        </button>
                    </>}
                >
                    {formaJSX}
                </Modal>
            )}

            {showEdit && (
                <Modal
                    title="Измени курс"
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
                        Да ли сте сигурни да желите да обришете курс{" "}
                        <span className="chl">{showDel.naziv}</span>?
                        Брисање неће бити могуће ако постоје групе или курсеви предуслови везани за њега.
                    </p>
                </Modal>
            )}
        </div>
    );
}