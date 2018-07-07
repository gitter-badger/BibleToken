// Allows us to use ES6 in our migrations and tests.
require('babel-register')

module.exports = {
    networks: {
	development: {
	    host: "localhost",
	    port: 7545,
	    network_id: '*', // Match any network id
	    gas:6721975
	}
    },

    solc: {
	optimizer: {
	    enabled: true,
	    runs: 200
	}
    }
};
