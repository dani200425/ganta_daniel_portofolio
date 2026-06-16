// Script.js
// Logica JavaScript pentru aplicația To-Do
// Observație: acest fișier presupune existența în HTML a elementelor:
// <input id="taskInput">, <button id="addBtn"> și <ul id="taskList">

// --- Configurare inițială și helper-e ---
const STORAGE_KEY = 'todo_tasks';

// Obține referințe la elementele din DOM
const taskInput = document.getElementById('taskInput');
const addBtn = document.getElementById('addBtn');
const taskList = document.getElementById('taskList');

// Asigură stil pentru animație fade-in și pentru clasa .done
// Injectăm un mic bloc CSS pentru a nu depinde de fișiere externe
(function injectStyles() {
    const css = `
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(6px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .fade-in {
            animation: fadeIn 240ms ease;
        }
        .todo-text.done {
            text-decoration: line-through;
            color: #999;
        }
        .todo-btn {
            border: none;
            background: transparent;
            cursor: pointer;
            font-size: 1rem;
            margin-left: 8px;
            padding: 4px;
            line-height: 1;
        }
        .todo-btn:focus { outline: 2px solid #cce; }
        li { display: flex; align-items: center; justify-content: space-between; padding: 6px 8px; }
        .left { display: flex; align-items: center; gap: 8px; flex: 1; }
        .todo-text { word-break: break-word; }
    `;
    const style = document.createElement('style');
    style.textContent = css;
    document.head.appendChild(style);
})();

// Încarcă lista din localStorage (sau returnează array gol)
function loadTasks() {
    try {
        const raw = localStorage.getItem(STORAGE_KEY);
        if (!raw) return [];
        const parsed = JSON.parse(raw);
        if (!Array.isArray(parsed)) return [];
        // Validăm că fiecare element are proprietățile așteptate
        return parsed.map(t => ({
            text: (typeof t.text === 'string') ? t.text : '',
            done: !!t.done
        }));
    } catch (e) {
        // În caz de date corupte, resetăm în siguranță
        console.warn('Could not parse tasks from localStorage, resetting.', e);
        return [];
    }
}

// Salvează lista în localStorage
function saveTasks(list) {
    try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
    } catch (e) {
        console.error('Could not save tasks to localStorage', e);
    }
}

// Listele din memorie
let tasks = loadTasks();

// Creează un element <li> pentru un task
function createTaskElement(task, index, animate = false) {
    const li = document.createElement('li');
    if (animate) li.classList.add('fade-in');

    // Container stânga: text + buton de marcare
    const left = document.createElement('div');
    left.className = 'left';

    const textSpan = document.createElement('span');
    textSpan.className = 'todo-text' + (task.done ? ' done' : '');
    textSpan.textContent = task.text;

    // Buton "✔️" - marchează / demarchează
    const doneBtn = document.createElement('button');
    doneBtn.className = 'todo-btn done-btn';
    doneBtn.type = 'button';
    doneBtn.title = task.done ? 'Debifează' : 'Marchează ca realizat';
    doneBtn.textContent = '✔️';
    // atribuim index ca dataset — index validează la acțiune (re-render păstrează consistența)
    doneBtn.dataset.index = index;

    left.appendChild(doneBtn);
    left.appendChild(textSpan);

    // Buton ștergere "✖️"
    const delBtn = document.createElement('button');
    delBtn.className = 'todo-btn del-btn';
    delBtn.type = 'button';
    delBtn.title = 'Șterge';
    delBtn.textContent = '✖️';
    delBtn.dataset.index = index;

    li.appendChild(left);
    li.appendChild(delBtn);

    return li;
}

// Rendează lista complet în DOM (reconstrucție sigură)
function renderTasks({ animateNew = false, newIndex = -1 } = {}) {
    // Golim lista curentă
    taskList.innerHTML = '';

    tasks.forEach((task, i) => {
        // animație doar pentru elementul proaspăt adăugat
        const animate = animateNew && i === newIndex;
        const li = createTaskElement(task, i, animate);
        taskList.appendChild(li);
    });
}

// Validează input-ul (prevenim task-uri goale)
function getTrimmedInput() {
    return (taskInput.value || '').trim();
}

// Adaugă un task nou în listă (dacă nu e gol)
function addTaskFromInput() {
    const text = getTrimmedInput();
    if (!text) {
        // prevenim erori la input gol — doar nu facem nimic
        taskInput.value = ''; // curățăm eventual spații
        return;
    }

    const newTask = { text, done: false };
    tasks.push(newTask);
    saveTasks(tasks);

    // Rerender și animație pe ultimul element
    renderTasks({ animateNew: true, newIndex: tasks.length - 1 });

    // curățăm input-ul și focusăm pentru a adăuga rapid următorul task
    taskInput.value = '';
    taskInput.focus();
}

// Toggle done state, index validat
function toggleTask(index) {
    if (!Number.isInteger(index) || index < 0 || index >= tasks.length) return;
    tasks[index].done = !tasks[index].done;
    saveTasks(tasks);
    renderTasks();
}

// Șterge task la index (validare)
function deleteTask(index) {
    if (!Number.isInteger(index) || index < 0 || index >= tasks.length) return;
    // Eliminăm elementul
    tasks.splice(index, 1);
    saveTasks(tasks);
    renderTasks();
}

// --- Evenimente ---

// Click pe butonul + (adăugare)
addBtn.addEventListener('click', () => {
    addTaskFromInput();
});

// Enter în input adaugă task
taskInput.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
        e.preventDefault();
        addTaskFromInput();
    }
});

// Delegare click pe lista de task-uri pentru butoanele ✔️ și ✖️
// Folosim dataset.index pentru a obține indexul corect la momentul re-render-ului
taskList.addEventListener('click', (e) => {
    const btn = e.target.closest('button');
    if (!btn) return;
    const idx = parseInt(btn.dataset.index, 10);
    if (btn.classList.contains('done-btn')) {
        toggleTask(idx);
    } else if (btn.classList.contains('del-btn')) {
        deleteTask(idx);
    }
});

// Încarcă și afișează task-urile la momentul încărcării paginii
document.addEventListener('DOMContentLoaded', () => {
    // reîncărcăm din storage (în caz că s-a modificat înainte de DOMContentLoaded)
    tasks = loadTasks();
    renderTasks();
});