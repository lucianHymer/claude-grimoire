// Sample Express.js application for testing chronicler
const express = require('express');
const mongoose = require('mongoose');
const redis = require('redis');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Database connection
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost/testapp');

// Redis client
const redisClient = redis.createClient({
    url: process.env.REDIS_URL || 'redis://localhost:6379'
});

// Routes
app.get('/', (req, res) => {
    res.json({ message: 'Test API', version: '1.0.0' });
});

app.get('/health', async (req, res) => {
    const dbStatus = mongoose.connection.readyState === 1 ? 'connected' : 'disconnected';
    const cacheStatus = redisClient.isOpen ? 'connected' : 'disconnected';
    
    res.json({
        status: 'healthy',
        database: dbStatus,
        cache: cacheStatus
    });
});

// Start server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});