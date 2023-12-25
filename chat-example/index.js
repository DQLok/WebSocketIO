// import required modules
import express from 'express'
import http from 'http'
import {Server} from 'socket.io'
import cors from 'cors'
// const http = require('http');
// const socketIO = require('socket.io');

// create the node app
const app = express();
// create the server
const server = http.createServer(app);
// setup socketio on the server
const io = new Server(3001,{cors:{origin:'*',methods:['GET','POST']}})
/// define the server port
const port = 3000;

// define the home route
app.get('/', (req, res) => {
    // render the index.html file
    res.sendFile(__dirname + '/index.html');
});

// function that handles socket.io connections
io.on('connection', (socket) => {
    // on connect print user connected msg
    console.log('A user connected.');

    // on socket disconnect
    socket.on('disconnect', () => {
        // print user disconnect msg
        console.log('A user disconnected.');
    });

    // Handle custom 'hello' event
    socket.on('hello', (data) => {
        console.log('Server Received hello event:', data);
        // Emit a response event
        socket.emit('response', 'Hello, client!');
    });
});

// function to listen on port
server.listen(port, () => {
  console.log(`Server is running on Port: ${port}`);
});