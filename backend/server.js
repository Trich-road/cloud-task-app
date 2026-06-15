const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Mongoose model (defined after connection) or in-memory fallback
let TaskModel = null;
let inMemory = { tasks: [], nextId: 1 };

async function initMongo() {
	const uri = process.env.MONGODB_URI;
	if (!uri) return;
	try {
		await mongoose.connect(uri, { useNewUrlParser: true, useUnifiedTopology: true });
		const taskSchema = new mongoose.Schema({
			title: { type: String, required: true },
			completed: { type: Boolean, default: false },
		}, { timestamps: true });
		TaskModel = mongoose.model('Task', taskSchema);
		console.log('Connected to MongoDB');
	} catch (err) {
		console.error('MongoDB connection error:', err.message || err);
	}
}

initMongo();

function mapDoc(doc) {
	if (!doc) return null;
	const obj = doc.toObject ? doc.toObject() : doc;
	return {
		id: obj._id ? String(obj._id) : obj.id,
		title: obj.title,
		completed: obj.completed,
		createdAt: obj.createdAt || obj.createdAt,
		updatedAt: obj.updatedAt || obj.updatedAt,
	};
}

// Helper CRUD functions that use MongoDB when available, otherwise in-memory
async function listTasks() {
	if (TaskModel) return (await TaskModel.find().sort({ createdAt: -1 })).map(mapDoc);
	return inMemory.tasks.slice().reverse();
}

async function createTask(data) {
	if (TaskModel) return mapDoc(await TaskModel.create({ title: data.title, completed: !!data.completed }));
	const task = { id: inMemory.nextId++, title: data.title, completed: !!data.completed, createdAt: new Date().toISOString() };
	inMemory.tasks.push(task);
	return task;
}

async function getTask(id) {
	if (TaskModel) return mapDoc(await TaskModel.findById(id));
	const num = Number(id);
	return inMemory.tasks.find(t => t.id === num) || null;
}

async function updateTask(id, data) {
	if (TaskModel) return mapDoc(await TaskModel.findByIdAndUpdate(id, { $set: data }, { new: true }));
	const num = Number(id);
	const task = inMemory.tasks.find(t => t.id === num);
	if (!task) return null;
	if (data.title !== undefined) task.title = data.title;
	if (data.completed !== undefined) task.completed = !!data.completed;
	task.updatedAt = new Date().toISOString();
	return task;
}

async function deleteTask(id) {
	if (TaskModel) {
		const doc = await TaskModel.findByIdAndDelete(id);
		return mapDoc(doc);
	}
	const num = Number(id);
	const idx = inMemory.tasks.findIndex(t => t.id === num);
	if (idx === -1) return null;
	return inMemory.tasks.splice(idx, 1)[0];
}

// Routes
app.get('/tasks', async (req, res) => {
	res.json(await listTasks());
});

app.post('/tasks', async (req, res) => {
	const { title, completed = false } = req.body;
	if (!title) return res.status(400).json({ error: 'Title required' });
	const task = await createTask({ title, completed });
	res.status(201).json(task);
});

app.get('/tasks/:id', async (req, res) => {
	const task = await getTask(req.params.id);
	if (!task) return res.status(404).json({ error: 'Not found' });
	res.json(task);
});

app.put('/tasks/:id', async (req, res) => {
	const { title, completed } = req.body;
	const task = await updateTask(req.params.id, { title, completed });
	if (!task) return res.status(404).json({ error: 'Not found' });
	res.json(task);
});

app.delete('/tasks/:id', async (req, res) => {
	const task = await deleteTask(req.params.id);
	if (!task) return res.status(404).json({ error: 'Not found' });
	res.json(task);
});

app.listen(PORT, () => {
	console.log(`Server listening on port ${PORT}`);
});

