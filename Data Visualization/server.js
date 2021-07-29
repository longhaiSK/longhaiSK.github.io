'use strict'
const express = require('express');
const bodyParser = require ('body-parser');


const PORT = 80;
const HOST = '0.0.0.0';
const PATH = __dirname + '/views'
var path = require('path');
const { time } = require('console');

const app = express();
app.use(bodyParser.urlencoded({extended:true}))
// app.use(bodyParser.urlencoded());
app.use(bodyParser.json());

app.use(express.static(__dirname + '/public/'))

app.set('views', path.join(__dirname, 'views'));

app.get("/index", function(req, res){
    console.log("from index")
    res.sendFile(PATH  + '/index.html')
})



app.listen(PORT,HOST);
