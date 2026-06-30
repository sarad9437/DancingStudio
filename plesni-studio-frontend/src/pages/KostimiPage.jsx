import { useState } from "react";
import Modal from "../components/Modal";
import { addKostim, updateKostim, deleteKostim } from "../data/api";

const PRAZNA_FORMA = { naziv: "", velicina: "M", boja: "" };

const VelicinaBadge = ({ velicina }) => (
    <span style={{
        background: "#fce8ea", color: "#c95a70", border: "1px solid #f0a0b0",
        fontSize: 11, fontWeight: 600, padding: "2px 9px",
        borderRadius: 99, display: "inline-block", letterSpacing: "0.2px"
    }}>
        {velicina}
    </span>
);

export default function KostimiPage({ kostimi, showToast, reload }) {
    const [search,   setSearch]   = useState("");
    const [showAdd,  setShowAdd]  = useState(false);
    const [showEdit, setShowEdit] = useState(null);
    const [showDel,  setShowDel]  = useState(null);
    const [loading,  setLoading]  = useState(false);
    const [forma,    setForma]    = useState(PRAZNA_FORMA);

    const zatvoriAdd  = () => { setShowAdd(false);  setForma(PRAZNA_FORMA); };
    const zatvoriEdit = () => { setShowEdit(null);  setForma(PRAZNA_FORMA); };

    const filtered = kostimi.filter(k =>
        `${k.naziv} ${k.boja}`.toLowerCase().includes(search.toLowerCase())
    );

    const handleAdd = async () => {
        if (!forma.naziv || !forma.boja) {
            showToast("Молимо попуните сва поља.", "error");
            return;
        }
        setLoading(true);
        try {
            await addKostim({ naziv: forma.naziv, velicina: forma.velicina, boja: forma.boja });
            showToast("Костим успешно додат.", "success");
            zatvoriAdd();
            reload();
        } catch (err) {
            showToast("Грешка: " + err.message, "error");
        } finally {
            setLoading(false);
        }
    };

    const handleEdit = async () => {
        if (!forma.naziv || !forma.boja) {
            showToast("Молимо попуните сва поља.", "error");
            return;
        }
        setLoading(true);
        try {
            await updateKostim(showEdit.id, {
                naziv: forma.naziv, velicina: forma.velicina, boja: forma.boja
            });
            showToast("Костим успешно измењен.", "success");
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
            await deleteKostim(showDel.id);
            showToast("Костим успешно обрисан.", "success");
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
                <label>Назив костима</label>
                <input
                    value={forma.naziv}
                    onChange={e => setForma({ ...forma, naziv: e.target.value })}
                    placeholder="нпр. Народна ношња"
                />
            </div>
            <div>
                <label>Величина</label>
                <select
                    value={forma.velicina}
                    onChange={e => setForma({ ...forma, velicina: e.target.value })}
                >
                    <option>XS</option>
                    <option>S</option>
                    <option>M</option>
                    <option>L</option>
                    <option>XL</option>
                </select>
            </div>
            <div>
                <label>Боја</label>
                <input
                    value={forma.boja}
                    onChange={e => setForma({ ...forma, boja: e.target.value })}
                    placeholder="нпр. Плава"
                />
            </div>
        </div>
    );

    return (
        <div>
            <div className="ph">
                <h2>Костими</h2>
                <p>Инвентар костима плесног студија · {filtered.length} резултата</p>
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
                        placeholder="Претрага по називу или боји..."
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
                    + Додај костим
                </button>
            </div>

            <div className="card">
                {filtered.length === 0 ? (
                    <div className="empty">
                        <p>{search ? `Нема резултата за „${search}"` : "Нема костима."}</p>
                    </div>
                ) : (
                    <div className="tw">
                        <table>
                            <thead>
                                <tr>
                                    <th>Назив</th>
                                    <th>Величина</th>
                                    <th>Боја</th>
                                    <th style={{ width: 1, whiteSpace: "nowrap" }}>Акције</th>
                                </tr>
                            </thead>
                            <tbody>
                                {filtered.map(k => (
                                    <tr key={k.id}>
                                        <td><strong>{k.naziv}</strong></td>
                                        <td><VelicinaBadge velicina={k.velicina} /></td>
                                        <td>{k.boja}</td>
                                        <td style={{ width: 1, whiteSpace: "nowrap" }}>
                                            <div className="acts">
                                                <button
                                                    className="btn btn-s btn-sm"
                                                    onClick={() => {
                                                        setShowEdit(k);
                                                        setForma({ naziv: k.naziv, velicina: k.velicina, boja: k.boja });
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
                    title="Додај костим"
                    onClose={zatvoriAdd}
                    footer={<>
                        <button className="btn btn-g" onClick={zatvoriAdd}>Откажи</button>
                        <button className="btn btn-p" onClick={handleAdd} disabled={loading}>
                            {loading ? "Чекај..." : "Додај костим"}
                        </button>
                    </>}
                >
                    {formaJSX}
                </Modal>
            )}

            {showEdit && (
                <Modal
                    title="Измени костим"
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
                        Да ли сте сигурни да желите да обришете костим{" "}
                        <span className="chl">{showDel.naziv} ({showDel.velicina}, {showDel.boja})</span>?
                    </p>
                </Modal>
            )}
        </div>
    );
}