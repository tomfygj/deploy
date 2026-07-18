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
        .error-shake {
            animation: shake 0.3s ease-in-out;
        }
        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }
        .toast {
            position: fixed;
            bottom: 100px;
            left: 50%;
            transform: translateX(-50%);
            background: rgba(0, 0, 0, 0.9);
            color: white;
            padding: 12px 20px;
            border-radius: 8px;
            z-index: 1000;
            animation: slideUp 0.3s ease-in-out;
        }
        @keyframes slideUp {
            from { transform: translateX(-50%) translateY(20px); opacity: 0; }
            to { transform: translateX(-50%) translateY(0); opacity: 1; }
        }
    </style>
</head>
<body>
    <div id="root"></div>
    <script type="text/babel">
        const { useState, useEffect, useRef } = React;
        
        const LucideIcon = ({ name, size = 20, className = "" }) => {
            return <i data-lucide={name} className={className} style={{ width: size, height: size }}></i>;
        };

        // Firebase Config
        const firebaseConfig = {
            apiKey: "AIzaSyAtXYwDag14X5YS8GZHV_3zANJxZn6R1nQ",
            authDomain: "gyme-3b2c0.firebaseapp.com",
            projectId: "gyme-3b2c0",
            storageBucket: "gyme-3b2c0.firebasestorage.app",
            messagingSenderId: "599463828481",
            appId: "1:599463828481:web:786524ce2d97a10a22f400",
            measurementId: "G-9XG9WJ9L8S"
        };

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

        // Validation utilities
        const validateExercise = (name) => name.trim().length > 0 && name.trim().length <= 50;
        const validateWeight = (w) => !isNaN(w) && w > 0 && w < 500;
        const validateReps = (r) => !isNaN(r) && r > 0 && r <= 100;
        const validateHeight = (h) => !isNaN(h) && h > 100 && h < 250;
        const validateAge = (a) => !isNaN(a) && a > 13 && a < 120;

        function Toast({ message, type = 'info' }) {
            return <div className={`toast ${type === 'error' ? 'bg-red-600' : 'bg-green-600'}`}>{message}</div>;
        }

        function App() {
            const [activeTab, setActiveTab] = useState('diary');
            const [user, setUser] = useState(null);
            const [loading, setLoading] = useState(true);
            const [syncing, setSyncing] = useState(false);
            const [toast, setToast] = useState(null);
            
            const [profile, setProfile] = useState({ weight: 85, height: 180, age: 25 });
            const [workouts, setWorkouts] = useState([]);
            const [records, setRecords] = useState([]);
            
            // Form states
            const [exerciseName, setExerciseName] = useState('');
            const [exerciseWeight, setExerciseWeight] = useState('');
            const [exerciseReps, setExerciseReps] = useState('');
            const [errors, setErrors] = useState({});

            // Initialize auth and sync data
            useEffect(() => {
                auth.signInAnonymously()
                    .then(cred => {
                        setUser(cred.user);
                        loadUserData(cred.user.uid);
                    })
                    .catch(err => {
                        console.error('Auth error:', err);
                        showToast('Chyba přihlášení', 'error');
                        setLoading(false);
                    });

                setTimeout(() => lucide.createIcons(), 500);
                window.addEventListener('online', syncData);
                window.addEventListener('offline', () => showToast('Offline mode', 'info'));
                
                return () => {
                    window.removeEventListener('online', syncData);
                };
            }, []);

            useEffect(() => { lucide.createIcons(); }, [activeTab]);

            const showToast = (message, type = 'info') => {
                setToast({ message, type });
                setTimeout(() => setToast(null), 3000);
            };

            const loadUserData = async (uid) => {
                try {
                    const docSnap = await db.collection('users').doc(uid).get();
                    if (docSnap.exists) {
                        const data = docSnap.data();
                        setProfile(data.profile || profile);
                        setWorkouts(data.workouts || []);
                        updateRecords(data.workouts || []);
                    }
                    setLoading(false);
                } catch (err) {
                    console.error('Load error:', err);
                    loadLocalData();
                    setLoading(false);
                }
            };

            const loadLocalData = () => {
                const localWorkouts = JSON.parse(localStorage.getItem('workouts')) || [];
                const localProfile = JSON.parse(localStorage.getItem('profile')) || profile;
                setProfile(localProfile);
                setWorkouts(localWorkouts);
                updateRecords(localWorkouts);
            };

            const updateRecords = (workoutsList) => {
                const uniqueExercises = [...new Set(workoutsList.map(w => w.exercise))];
                const recordsList = uniqueExercises.map(ex => {
                    const best = workoutsList
                        .filter(w => w.exercise.toLowerCase() === ex.toLowerCase())
                        .reduce((max, w) => parseFloat(w.weight) > parseFloat(max.weight) ? w : max);
                    return { exercise: ex, ...best };
                });
                setRecords(recordsList);
            };

            const syncData = async () => {
                if (!user) return;
                setSyncing(true);
                try {
                    await db.collection('users').doc(user.uid).set({
                        profile,
                        workouts,
                        lastSync: new Date()
                    });
                    showToast('Data synced', 'info');
                } catch (err) {
                    console.error('Sync error:', err);
                    showToast('Sync failed', 'error');
                } finally {
                    setSyncing(false);
                }
            };

            const addWorkout = () => {
                const newErrors = {};
                
                if (!validateExercise(exerciseName)) newErrors.exercise = 'Invalid exercise name';
                if (!validateWeight(exerciseWeight)) newErrors.weight = 'Weight: 0-500 kg';
                if (!validateReps(exerciseReps)) newErrors.reps = 'Reps: 1-100';

                if (Object.keys(newErrors).length > 0) {
                    setErrors(newErrors);
                    showToast('Check all fields', 'error');
                    return;
                }

                const newWorkout = {
                    id: Date.now(),
                    exercise: exerciseName.trim(),
                    weight: parseFloat(exerciseWeight),
                    reps: parseInt(exerciseReps),
                    date: new Date().toISOString(),
                    synced: false
                };

                const updated = [newWorkout, ...workouts];
                setWorkouts(updated);
                updateRecords(updated);
                localStorage.setItem('workouts', JSON.stringify(updated));
                
                setExerciseName('');
                setExerciseWeight('');
                setExerciseReps('');
                setErrors({});
                
                showToast('Workout added!', 'info');
                
                if (navigator.onLine) {
                    syncData();
                }
            };

            const updateProfile = (key, value) => {
                let isValid = true;
                if (key === 'height') isValid = validateHeight(value);
                else if (key === 'age') isValid = validateAge(value);
                else if (key === 'weight') isValid = validateWeight(value);

                if (!isValid) {
                    setErrors({ ...errors, [key]: `Invalid ${key}` });
                    return;
                }

                const updated = { ...profile, [key]: parseFloat(value) };
                setProfile(updated);
                localStorage.setItem('profile', JSON.stringify(updated));
                setErrors({});

                if (navigator.onLine) {
                    syncData();
                }
            };

            const deleteWorkout = (id) => {
                const updated = workouts.filter(w => w.id !== id);
                setWorkouts(updated);
                updateRecords(updated);
                localStorage.setItem('workouts', JSON.stringify(updated));
                if (navigator.onLine) syncData();
            };

            const getRank = (ex, w) => {
                const ratio = w / profile.weight;
                const key = ex.toLowerCase().replace(/\s/g, "");
                const std = STRENGTH_STANDARDS[key] || STRENGTH_STANDARDS.benchpress;
                if (ratio >= std.elite) return { label: 'ELITE', color: 'text-red-500', pct: 95 };
                if (ratio >= std.advanced) return { label: 'ADVANCED', color: 'text-orange-500', pct: 80 };
                return { label: 'INTERMEDIATE', color: 'text-yellow-500', pct: 50 };
            };

            const calculateScore = () => {
                if (records.length === 0) return 0;
                return Math.round(records.reduce((sum, r) => sum + getRank(r.exercise, r.weight).pct, 0) / records.length);
            };

            if (loading) {
                return (
                    <div className="min-h-screen flex items-center justify-center bg-[#07090C]">
                        <div className="text-white text-center">
                            <div className="animate-spin mb-4"><LucideIcon name="loader" size={40} /></div>
                            <p>Loading...</p>
                        </div>
                    </div>
                );
            }

            return (
                <div className="min-h-screen pb-32 flex flex-col items-center bg-[#07090C]">
                    {toast && <Toast {...toast} />}
                    
                    <header className="w-full max-w-md p-6 flex justify-between items-center sticky top-0 bg-[#07090C]/80 backdrop-blur-md z-50">
                        <div className="flex items-center gap-2">
                            <div className="bg-red-600 p-2 rounded-lg">
                                <LucideIcon name="zap" size={20} className="text-white" />
                            </div>
                            <h1 className="text-xl font-black italic uppercase tracking-tighter text-white">FRANCIS <span className="text-red-600">LIFTS</span></h1>
                        </div>
                        <div className="flex items-center gap-2">
                            {syncing && <LucideIcon name="loader" size={18} className="text-blue-500 animate-spin" />}
                            <LucideIcon name="user" className="text-slate-500" />
                        </div>
                    </header>

                    <main className="w-full max-w-md px-4 space-y-6">
                        
                        {activeTab === 'diary' && (
                            <div className="space-y-4 animate-in fade-in">
                                {/* Profile Quick Stats */}
                                <div className="bg-[#12161D] p-6 rounded-3xl border border-white/5">
                                    <div className="grid grid-cols-3 gap-4">
                                        <div className="text-center">
                                            <div className="text-[10px] text-slate-500 uppercase font-bold">Váha</div>
                                            <div className="text-2xl font-black text-white mt-1">{profile.weight}kg</div>
                                        </div>
                                        <div className="text-center border-l border-r border-white/5">
                                            <div className="text-[10px] text-slate-500 uppercase font-bold">Výška</div>
                                            <div className="text-2xl font-black text-white mt-1">{profile.height}cm</div>
                                        </div>
                                        <div className="text-center">
                                            <div className="text-[10px] text-slate-500 uppercase font-bold">Věk</div>
                                            <div className="text-2xl font-black text-white mt-1">{profile.age}</div>
                                        </div>
                                    </div>
                                </div>

                                {/* Add Workout */}
                                <div className="bg-[#12161D] p-6 rounded-3xl border border-white/5">
                                    <h2 className="text-[10px] font-black uppercase tracking-widest text-red-500 mb-4">Přidat trénink</h2>
                                    <div className="space-y-4">
                                        <input 
                                            placeholder="Cvik (např. Bench Press)"
                                            value={exerciseName}
                                            onChange={e => setExerciseName(e.target.value)}
                                            className={`w-full bg-[#0B0F15] border p-4 rounded-2xl text-white outline-none focus:border-red-500/50 transition ${errors.exercise ? 'border-red-500 error-shake' : 'border-white/5'}`}
                                        />
                                        {errors.exercise && <p className="text-red-500 text-xs">{errors.exercise}</p>}
                                        
                                        <div className="grid grid-cols-2 gap-4">
                                            <div>
                                                <input 
                                                    type="number" 
                                                    placeholder="Váha (kg)"
                                                    value={exerciseWeight}
                                                    onChange={e => setExerciseWeight(e.target.value)}
                                                    className={`w-full bg-[#0B0F15] border p-4 rounded-2xl text-white text-center font-bold outline-none focus:border-red-500/50 transition ${errors.weight ? 'border-red-500' : 'border-white/5'}`}
                                                />
                                                {errors.weight && <p className="text-red-500 text-[9px] mt-1">{errors.weight}</p>}
                                            </div>
                                            <div>
                                                <input 
                                                    type="number" 
                                                    placeholder="Opakování"
                                                    value={exerciseReps}
                                                    onChange={e => setExerciseReps(e.target.value)}
                                                    className={`w-full bg-[#0B0F15] border p-4 rounded-2xl text-white text-center font-bold outline-none focus:border-red-500/50 transition ${errors.reps ? 'border-red-500' : 'border-white/5'}`}
                                                />
                                                {errors.reps && <p className="text-red-500 text-[9px] mt-1">{errors.reps}</p>}
                                            </div>
                                        </div>
                                        
                                        <button 
                                            onClick={addWorkout}
                                            className="w-full bg-red-600 p-4 rounded-2xl font-black uppercase text-xs tracking-widest shadow-lg shadow-red-900/20 active:scale-95 transition-transform"
                                        >
                                            Uložit Trénink
                                        </button>
                                    </div>
                                </div>

                                {/* Recent Workouts */}
                                <div className="space-y-3">
                                    <h3 className="text-[10px] font-black uppercase tracking-widest text-white/40 px-2">Poslední tréninky</h3>
                                    {workouts.length === 0 ? (
                                        <div className="bg-[#12161D] p-8 rounded-3xl text-center">
                                            <p className="text-slate-500 text-sm">Zatím žádné tréninky</p>
                                        </div>
                                    ) : (
                                        workouts.slice(0, 5).map(w => (
                                            <div key={w.id} className="bg-[#12161D] p-4 rounded-2xl border border-white/5 flex justify-between items-center">
                                                <div>
                                                    <div className="text-sm font-black text-white">{w.exercise}</div>
                                                    <div className="text-[10px] text-slate-500">{w.weight}kg × {w.reps}</div>
                                                </div>
                                                <button 
                                                    onClick={() => deleteWorkout(w.id)}
                                                    className="p-2 text-slate-500 hover:text-red-500 transition"
                                                >
                                                    <LucideIcon name="trash2" size={16} />
                                                </button>
                                            </div>
                                        ))
                                    )}
                                </div>
                            </div>
                        )}

                        {activeTab === 'prs' && (
                            <div className="space-y-4 animate-in fade-in">
                                <div className="bg-gradient-to-br from-red-600 to-red-900 p-6 rounded-3xl shadow-xl border border-white/10">
                                    <span className="text-[10px] font-black uppercase text-white/60">Francis Score</span>
                                    <div className="text-5xl font-black italic text-white mt-2">{calculateScore()}</div>
                                    <p className="text-[9px] text-white/50 uppercase font-bold mt-2">Tvoje průměrná úroveň</p>
                                </div>

                                {records.length === 0 ? (
                                    <div className="bg-[#12161D] p-8 rounded-3xl text-center">
                                        <p className="text-slate-500">Přidej tréninky pro zobrazení</p>
                                    </div>
                                ) : (
                                    records.map((r, idx) => {
                                        const rank = getRank(r.exercise, r.weight);
                                        return (
                                            <div key={idx} className="bg-[#12161D] p-5 rounded-3xl border border-white/5 flex justify-between items-center">
                                                <div>
                                                    <h3 className="text-xs font-black uppercase text-slate-500 mb-1">{r.exercise}</h3>
                                                    <div className="text-2xl font-black italic text-white">{r.weight}kg</div>
                                                    <span className={`text-[9px] font-black ${rank.color}`}>{rank.label}</span>
                                                </div>
                                                <div className="text-right">
                                                    <div className="text-[10px] text-slate-500 font-bold uppercase mb-1">Percentil</div>
                                                    <div className="text-xl font-black text-white">{rank.pct}%</div>
                                                </div>
                                            </div>
                                        );
                                    })
                                )}
                            </div>
                        )}

                        {activeTab === 'profile' && (
                            <div className="space-y-4 animate-in fade-in">
                                <div className="bg-[#12161D] p-6 rounded-3xl border border-white/5">
                                    <h2 className="text-[10px] font-black uppercase tracking-widest text-red-500 mb-4">Tvůj Profil</h2>
                                    
                                    <div className="space-y-4">
                                        <div>
                                            <label className="text-[10px] font-black uppercase text-white/40 mb-2 block">Věk</label>
                                            <input 
                                                type="number"
                                                value={profile.age}
                                                onChange={e => updateProfile('age', e.target.value)}
                                                className={`w-full bg-[#0B0F15] border p-4 rounded-2xl text-white text-center font-bold outline-none focus:border-red-500/50 transition ${errors.age ? 'border-red-500' : 'border-white/5'}`}
                                            />
                                            {errors.age && <p className="text-red-500 text-xs mt-1">{errors.age}</p>}
                                        </div>

                                        <div>
                                            <label className="text-[10px] font-black uppercase text-white/40 mb-2 block">Váha (kg)</label>
                                            <input 
                                                type="number"
                                                value={profile.weight}
                                                onChange={e => updateProfile('weight', e.target.value)}
                                                className={`w-full bg-[#0B0F15] border p-4 rounded-2xl text-white text-center font-bold outline-none focus:border-red-500/50 transition ${errors.weight ? 'border-red-500' : 'border-white/5'}`}
                                            />
                                            {errors.weight && <p className="text-red-500 text-xs mt-1">{errors.weight}</p>}
                                        </div>

                                        <div>
                                            <label className="text-[10px] font-black uppercase text-white/40 mb-2 block">Výška (cm)</label>
                                            <input 
                                                type="number"
                                                value={profile.height}
                                                onChange={e => updateProfile('height', e.target.value)}
                                                className={`w-full bg-[#0B0F15] border p-4 rounded-2xl text-white text-center font-bold outline-none focus:border-red-500/50 transition ${errors.height ? 'border-red-500' : 'border-white/5'}`}
                                            />
                                            {errors.height && <p className="text-red-500 text-xs mt-1">{errors.height}</p>}
                                        </div>
                                    </div>
                                </div>
                            </div>
                        )}

                        {activeTab === 'calc' && (
                            <div className="space-y-4 animate-in fade-in">
                                <div className="bg-[#12161D] p-6 rounded-3xl border border-white/5 text-center">
                                    <h2 className="text-[10px] font-black uppercase tracking-widest text-red-500 mb-4">Kalkulačka 1RM</h2>
                                    <p className="text-slate-500 text-sm">Coming soon...</p>
                                </div>
                            </div>
                        )}
                    </main>

                    <nav className="fixed bottom-6 w-[90%] max-w-md bg-[#12161D]/90 backdrop-blur-xl border border-white/10 p-2 rounded-3xl flex justify-between items-center shadow-2xl z-50">
                        {[
                            { id: 'diary', icon: 'calendar', label: 'Deník' },
                            { id: 'prs', icon: 'award', label: 'Best' },
                            { id: 'profile', icon: 'user', label: 'Profil' },
                            { id: 'calc', icon: 'calculator', label: '1RM' }
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