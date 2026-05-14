<!DOCTYPE html>
<html lang="cs">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <title>Francis Lifts</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/react@18/umd/react.production.min.js"></script>
    <script src="https://unpkg.com/react-dom@18/umd/react-dom.production.min.js"></script>
    <script src="https://unpkg.com/@babel/standalone/babel.min.js"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.22.0/firebase-firestore-compat.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;700;900&display=swap');
        body { 
            font-family: 'Inter', sans-serif; 
            background-color: #07090C; 
            margin: 0; 
            overflow-x: hidden;
            -webkit-tap-highlight-color: transparent;
            user-select: none;
        }
        .custom-scroll::-webkit-scrollbar { display: none; }
        input, select { font-size: 16px !important; }
    </style>
</head>
<body>
    <div id="root"></div>
    <script type="text/babel">
        const { useState, useEffect } = React;
        const LucideIcon = ({ name, size = 20, className = "" }) => {
            return <i data-lucide={name} className={className} style={{ width: size, height: size }}></i>;
        };
        const firebaseConfig = { apiKey: "", authDomain: "", projectId: "", storageBucket: "", messagingSenderId: "", appId: "" };
        if (!firebase.apps.length) {
            firebase.initializeApp(firebaseConfig);
        }
        const auth = firebase.auth();
        const db = firebase.firestore();
        const STRENGTH_STANDARDS = {
            benchpress: { intermediate: 1.1, advanced: 1.45, elite: 1.8 },
            deadlift: { intermediate: 1.85, advanced: 2.35, elite: 2.9 },
            squat: { intermediate: 1.5, advanced: 2.0, elite: 2.5 }
        };
        function App() {
            const [activeTab, setActiveTab] = useState('diary');
            const [user, setUser] = useState(null);
            const [profile, setProfile] = useState({ weight: 85, height: 180 });
            const [records, setRecords] = useState([
                { id: 1, exercise: 'Bench Press', weight: 100 },
                { id: 2, exercise: 'Deadlift', weight: 180 },
                { id: 3, exercise: 'Squat', weight: 140 }
            ]);
            useEffect(() => {
                auth.signInAnonymously().then(cred => setUser(cred.user)).catch(() => {});
                setTimeout(() => lucide.createIcons(), 500);
            }, []);
            useEffect(() => { lucide.createIcons(); }, [activeTab]);
            const getRank = (ex, w) => {
                const ratio = w / profile.weight;
                const key = ex.toLowerCase().replace(" ", "");
                const std = STRENGTH_STANDARDS[key] || STRENGTH_STANDARDS.benchpress;
                if (ratio >= std.elite) return { label: 'ELITE', color: 'text-red-500', pct: 95 };
                if (ratio >= std.advanced) return { label: 'ADVANCED', color: 'text-orange-500', pct: 80 };
                return { label: 'INTERMEDIATE', color: 'text-yellow-500', pct: 50 };
            };
            return (
                <div className="min-h-screen pb-32 flex flex-col items-center">
                    <header className="w-full max-w-md p-6 flex justify-between items-center sticky top-0 bg-[#07090C]/80 backdrop-blur-md z-50">
                        <div className="flex items-center gap-2">
                            <div className="bg-red-600 p-2 rounded-lg">
                                <LucideIcon name="zap" size={20} className="text-white" />
                            </div>
                            <h1 className="text-xl font-black italic uppercase tracking-tighter text-white">FRANCIS <span className="text-red-600">LIFTS</span></h1>
                        </div>
                        <LucideIcon name="user" className="text-slate-500" />
                    </header>
                    <main className="w-full max-w-md px-4 space-y-6">
                        {activeTab === 'diary' && (
                            <div className="space-y-4 animate-in fade-in slide-in-from-bottom-4">
                                <div className="bg-[#12161D] p-6 rounded-3xl border border-white/5 shadow-2xl">
                                    <h2 className="text-[10px] font-black uppercase tracking-widest text-red-500 mb-4">Zapsat dnešní trénink</h2>
                                    <div className="space-y-4">
                                        <input placeholder="Cvik (např. Bench)" className="w-full bg-[#0B0F15] border border-white/5 p-4 rounded-2xl text-white outline-none focus:border-red-500/50" />
                                        <div className="grid grid-cols-2 gap-4">
                                            <input type="number" placeholder="Váha (kg)" className="bg-[#0B0F15] border border-white/5 p-4 rounded-2xl text-white text-center font-bold" />
                                            <input type="number" placeholder="Reps" className="bg-[#0B0F15] border border-white/5 p-4 rounded-2xl text-white text-center font-bold" />
                                        </div>
                                        <button className="w-full bg-red-600 p-4 rounded-2xl font-black uppercase text-xs tracking-widest shadow-lg shadow-red-900/20 active:scale-95 transition-transform">Uložit sérii</button>
                                    </div>
                                </div>
                            </div>
                        )}
                        {activeTab === 'prs' && (
                            <div className="space-y-4 animate-in fade-in">
                                <div className="bg-gradient-to-br from-red-600 to-red-900 p-6 rounded-3xl shadow-xl border border-white/10">
                                    <span className="text-[10px] font-black uppercase text-white/60">Francis Score</span>
                                    <div className="text-4xl font-black italic text-white mt-1">842</div>
                                    <p className="text-[9px] text-white/50 uppercase font-bold mt-2">Jsi silnější než 78% populace</p>
                                </div>
                                {records.map(r => {
                                    const rank = getRank(r.exercise, r.weight);
                                    return (
                                        <div key={r.id} className="bg-[#12161D] p-5 rounded-3xl border border-white/5 flex justify-between items-center">
                                            <div>
                                                <h3 className="text-xs font-black uppercase text-slate-500 mb-1">{r.exercise}</h3>
                                                <div className="text-2xl font-black italic text-white">{r.weight}kg</div>
                                                <span className={`text-[9px] font-black ${rank.color}`}>{rank.label} LEVEL</span>
                                            </div>
                                            <div className="text-right">
                                                <div className="text-[10px] text-slate-500 font-bold uppercase mb-1">Percentil</div>
                                                <div className="text-xl font-black text-white">{rank.pct}%</div>
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        )}
                    </main>
                    <nav className="fixed bottom-6 w-[90%] max-w-md bg-[#12161D]/90 backdrop-blur-xl border border-white/10 p-2 rounded-3xl flex justify-between items-center shadow-2xl z-50">
                        {[
                            { id: 'diary', icon: 'history', label: 'Deník' },
                            { id: 'prs', icon: 'award', label: 'Ranky' },
                            { id: 'ai', icon: 'message-square', label: 'Coach' },
                            { id: 'calc', icon: 'calculator', label: 'Kalk' }
                        ].map(t => (
                            <button 
                                key={t.id} 
                                onClick={() => setActiveTab(t.id)}
                                className={`flex-1 flex flex-col items-center gap-1 py-3 rounded-2xl transition-all ${activeTab === t.id ? 'bg-red-600 text-white shadow-lg' : 'text-slate-500'}`}
                            >
                                <LucideIcon name={t.icon} size={18} />
                                <span className="text-[8px] font-black uppercase">{t.label}</span>
                            </button>
                        ))}
                    </nav>
                </div>
            );
        }
        const root = ReactDOM.createRoot(document.getElementById('root'));
        root.render(<App />);
    </script>
</body>
</html>
