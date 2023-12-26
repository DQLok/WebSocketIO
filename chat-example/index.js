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

    socket.on('chat_message', (msg) => {
        console.log('message: ' , msg);
        if (msg['jwt'] == jwt) {
            socket.emit('chat_message', msg);
        } else {
            console.log('message: ' , 'Send Msg Fail');
        }
    });

    const jwt = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiU29ja2V0IEZsdXR0ZXIifQ.fPsjjKmkppWHNlnWbECNA77-SaBXQpNqvh71hw78Cp0";
    
    socket.on('login_jwt', (msg) => {
        socket.emit('login_jwt', jwt);
    });

    socket.on('msg_auto', (msg) => {
        if (msg == jwt){
        var number =0;
        setInterval(function() {
            number +=1;
            socket.emit('msg_auto', number);
        }, 5000);  
        } else {
            socket.emit('msg_auto', "Wrong JWT");
        }   
    });
});

// function to listen on port
server.listen(port, () => {
  console.log(`Server is running on Port: ${port}`);
});