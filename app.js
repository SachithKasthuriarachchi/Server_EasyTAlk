const express = require('express')
const app = express()
const mongoClient = require('mongodb').MongoClient
const bcrypt = require('bcrypt')
const {exec} = require('child_process')
const url = "mongodb://localhost:27017"

app.use(express.json())

mongoClient.connect(url,{useNewUrlParser: true, useUnifiedTopology: true}, (err, client) => {
    if (err) {
        console.log("Error while connecting to the database")
    } else {
        const database = client.db('users')
        const table = database.collection('credentials')
        
        //Requests
        app.post('/signup', async (req, res) => {
            try {
                //generating the salt and the hashed password using bcrypt
                const hashedPassword = await bcrypt.hash(req.body.password, 10)
            
                const newUser = {
                    name: req.body.name,
                    password: hashedPassword
                }

                //Checking if there is no users with same name
                const query = {name: newUser.name}
                table.findOne(query, (err, result) => {
                if (result == null) {
                    table.insertOne(newUser, (err, result) => {
                        res.status(200).send()
                    })
                    exec(`kamctl add ${newUser.name} ${req.body.password}`,(err, stdOut, stdErr) => {
                        if (err) {
                            console.log(err)
                        } else {
                            console.log(`stdout: ${stdOut}`)
                            console.log(`stderr: ${stdErr}`)
                        }
                    })

                } else {
                    //bad request(user already registered)
                    res.status(400).send()
                }
            })
            } catch {
                //If something went wrong
                res.status(500).send()
            }
            
        })

        app.post('/signin', async (req, res) => {
            const query = {name: req.body.name}
            table.findOne(query, async (err, result) => {
                if (result == null) {
                    res.status(404).send('No such username exists')
                } else {
                    console.log("Before trying")
                    try {
                        if (await bcrypt.compare(req.body.password, result.password, (err, same) => {
                            if (same) {
                                console.log(req.body.password)
                                console.log(result.password)
                                res.status(200).send('Successfully signed in')
                            } else {
                                console.log('Wrong Password')
                                res.status(404).send('Wrong password')
                            }
                        })) return
                    } catch {
                        res.status(500).send()
                    }
                }
            })
        })
    }
})
app.listen(3000, () => {
    console.log("Server Started!")
})