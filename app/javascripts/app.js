// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
// import bibleTokenCore_artifacts from '../../build/contracts/BibleTokenCore.json'
// var BibleTokenCore = contract(bibleTokenCore_artifacts);

window.App = {
    web3provider: null,
    contracts: {},
    account: '0x0',

    init: function() {
	return App.initWeb3();
    },

    initWeb3: function() {
	if(typeof web3 !== 'undefined') {
	    // If a web3 instance is already provided by Meta Mask.
	    App.web3Provider = web3.currentProvider;
	    web3 = new Web3(web3.currentProvider);
	} else {
	    // Specify default instance if no web3 instance provided.
	    App.web3Provider = new Web3.providers.httpProvider('http://localhost:7545');
	    web3 = new Web3(App.web3Provider);
	}
	
	return App.initContract();
    },

    initContract: function() {
	$.getJSON("../../build/contracts/BibleTokenCore.json", function(bibleTokenCore) {
	    // Instantiate a new truffle contract from the artifact.
	    App.contracts.BibleTokenCore = TruffleContract(bibleTokenCore);
	    // Connect provider to interact with the contract.
	    App.contracts.BibleTokenCore.setProvider(App.web3Provider);

	    window.App.listenForEvents();

	    return App.render();
	});
    },

    render: function() {
	var bibleTokenCoreInstance;
	var bookName = 'Genesis';
	var chapterNumber = '1';
	var verseNumber = '1';

	// Load account data.
	web3.eth.getCoinbase(function(err, account) {
	    if(err === null) {
		App.account = account;
		$("#accountAddress").html(account);
	    }
	});

	// Load contract data.
	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.contractBalance();
	}).then(function(ret) {
	    $("#contractBalance").html(window.web3.fromWei(ret.toString(), 'ether') + " Ether");
	});
	
	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.booksCompleted();
	}).then(function(ret) {
	    $("#booksCompleted").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.currentBookName();
	}).then(function(ret) {
	    bookName = ret;
	    $("#currentBookName").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.currentNumberOfChapters();
	}).then(function(ret) {
	    $("#currentNumberOfChapters").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.currentChapterNumber();
	}).then(function(ret) {
	    chapterNumber = ret.toString();
	    $("#currentChapterNumber").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.currentChapterVersesNumber();
	}).then(function(ret) {
	    $("#currentChapterVersesNumber").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.currentVerseNumber();
	}).then(function(ret) {
	    verseNumber = ret.toString();
	    $("#currentVerseNumber").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.price();
	}).then(function(ret) {
	    $("#price").html(window.web3.fromWei(ret.toString(), 'ether') + " Ether");
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.mintVerseGasLimit();
	}).then(function(ret) {
	    $("#mintVerseGasLimit").html(ret.toString() + " gas");
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.updateBookNameGasLimit();
	}).then(function(ret) {
	    $("#updateBookNameGasLimit").html(ret.toString() + " gas");
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.updateNumberOfChaptersGasLimit();
	}).then(function(ret) {
	    $("#updateNumberOfChaptersGasLimit").html(ret.toString() + " gas");
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.updateChapterVersesIGasLimit();
	}).then(function(ret) {
	    $("#updateChapterVersesIGasLimit").html(ret.toString() + " gas");
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.updateChapterVersesIIGasLimit();
	}).then(function(ret) {
	    $("#updateChapterVersesIIGasLimit").html(ret.toString() + " gas");
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.queryCount();
	}).then(function(ret) {
	    $("#queryCount").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.halted();
	}).then(function(ret) {
	    $("#halted").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.contractCanMint();
	}).then(function(ret) {
	    $("#contractCanMint").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.owner();
	}).then(function(ret) {
	    $("#owner").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.paused();
	}).then(function(ret) {
	    $("#paused").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.totalSupply();
	}).then(function(ret) {
	    $("#totalSupply").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.name();
	}).then(function(ret) {
	    $("#name").html(ret.toString());
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    bibleTokenCoreInstance = instance;
	    return bibleTokenCoreInstance.symbol();
	}).then(function(ret) {
	    $("#symbol").html(ret.toString());
	});
    },

    mint: function() {
	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    return instance.mint({from: App.account, value: '60000000000000000', gas: '300000', gasPrice: '20000000000'});
	});
	
    },

    retrieveVerse: function() {
	var bookName = document.getElementById("bookName").value;
	var chapterNumber = document.getElementById("chapterNumber").value;
	var verseNumber = document.getElementById("verseNumber").value;
	var text = bookName + " " + chapterNumber + ":" + verseNumber + " ";
	
	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    return instance.retrieveVerse(bookName, chapterNumber, verseNumber);
	}).then(function(ret) {
	    $("#verse").html(text + "\"" + ret.toString() + "\"");
	});
    },

    listenForEvents: function() {
	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    instance.Halt({}, {
	    }).watch(function(error, event) {
		console.log("event triggered", event)
		window.App.render();
	    });
	});

	App.contracts.BibleTokenCore.deployed().then(function(instance) {
	    instance.Unhalt({}, {
	    }).watch(function(error, event) {
		console.log("event triggered", event)
		window.App.render();
	    });
	});
    }
};

window.addEventListener('load', function() {
    App.init();
});
