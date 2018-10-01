(
var b_speech, sd_playSpeech, speechStarts, speechDurs, oscAddress;

oscAddress = NetAddr("127.0.0.1", NetAddr.langPort); // loopback

speechStarts = File("/Users/erikparr/Documents/_2017/AudioNotebooks/data/speech/start_samples.txt","rb");
speechDurs = File("/Users/erikparr/Documents/_2017/AudioNotebooks/data/speech/durations.txt","rb");

//txt_startTimes.readAllString.postln;


//speechStarts = ;
speechStarts = speechStarts.readAllString.split($\n);
speechDurs = speechDurs.readAllString.split($\n);


b_speech = CtkBuffer.playbuf("/Users/erikparr/Documents/_2017/AudioNotebooks/data/speech/samples/spritesheet.wav").load(sync: true); // load and sync with the server

sd_playSpeech = CtkSynthDef("sd_playSpeech", {arg bus = 0, buf = 0, dur, startPos;
	var env, src;
	src = PlayBuf.ar(1, buf, BufRateScale.kr(buf), startPos:startPos );
	env = EnvGen.ar(Env([0, 1, 0], [0.5, 0.5], \sin),timeScale: dur, doneAction:2);
	Out.ar(bus, Pan2.ar(env*src*2))
});


//sd_playSpeech.note.buf(b).out_(0).play;


p = ProcMod .new(Env([0, 1, 0], [1,1], \sin, 1), target:1, addAction:\tail)
// the unique Group id created by ProcModR is passed in to this function,
// as well as the unique routing bus and the server, as well as the ProcModR itself
.function_({arg group, routebus, server, pm;
	var task, globalDur, durMask;
	globalDur = 60;

	task =  Task({//some args here
		arg i;
		var noteDur, playnote, modnote, index;
			index = speechDurs.size/2;

		speechDurs.size.do({arg i;
			playnote = sd_playSpeech.note(target: group, addAction: \addToHead)
			.buf_(b_speech)
			.dur_(speechDurs[index].asFloat)
			.startPos_(speechStarts[index].asInt)
			.bus_(0)
			.play;

			oscAddress.sendMsg("/chat", "Hello App 1");

			// playnote.release(noteDur);

			(speechDurs[index].asFloat*2).wait;
			pm.now.postln;
			index=index-1;
			// s.queryAllNodes;
		});
	});
	task;
});

)
p.play
p.release