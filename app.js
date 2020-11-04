const express = require('express')
const app = express()
const mongoClient = require('mongodb').MongoClient
const url = "mongodb://localhost:27017"

app.use(express.json())

mongoClient.connect(url,{useNewUrlParser: true, useUnifiedTopology: true}, (err, client) => {
    if (err) {
        console.log("Error while connecting to the database")
    } else {
        const database = client.db('users')
        const table = database.collection('credentials')
        
        //Requests
        app.post('/signup', (req, res) => {
            const newUser = {
                name: req.body.name,
                password: req.body.password
            }

            //Checking if there is no users with same name
            const query = {name: newUser.name}
            table.findOne(query, (err, result) => {
                if (result == null) {
                    table.insertOne(newUser, (err, result) => {
                        res.status(200).send()
                    })
                } else {
                    //bad request(user already registered)
                    res.status(400).send()
                }
            })
        })
    }
})
app.listen(3000, () => {
    console.log("Hello Sachith")
})