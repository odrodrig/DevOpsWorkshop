//Run Mocha test

let chai = require('chai');
let chaiHttp = require('chai-http');
let server = require('../server.js');
let should = chai.should();

chai.use(chaiHttp);

describe('GET /sayHello', () => {
    it("should echo a user's name back", (done) => {
        chai.request(server)
            .get('/sayHello')
            .query({user_name: "test dummy"})
            .end((err, res) => {
                res.should.have.status(200);
                res.text.should.equal("Hello test dummy!");
            })
            done();
    });
});