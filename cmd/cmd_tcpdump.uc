{%
	let serial = cursor.get("ucentral", "config", "serial");

	if (!serial)
		return;

	if (args.network) {
		let net = ctx.call("network.interface", "status", { interface: args.network });

		if (!net || !net.l3_device) {
			result({
				"error": 1,
				"text": "Failed",
				"resultCode": 1,
				"resultText": sprintf("Unable to resolve logical interface %s", args.network)
			});

			return;
		}

		args.iface = net.l3_device;
	}

	if (!match(args.iface, /^[^\/]+$/) || (args.iface != "any" && !fs.stat("/sys/class/net/" + args.iface))) {
		result({
			"error": 1,
			"text": "Failed",
			"resultCode": 1,
			"resultText": "Invalid network device specified"
		});

		return;
	}

	let duration = +args.duration || 30;
	let filename = sprintf("/tmp/pcap-%s-%d", serial, time());

	let rc = system([
		'tcpdump',
		'-c', '1000',
		'-W', '1',
		'-G', duration,
		'-w', filename,
		'-i', args.iface
	]);

	if (rc != 0) {
		result({
			"error": 1,
			"text": "Failed",
			"resultCode": rc,
			"resultText": "tcpdump command exited with non-zero code"
		});

		return;
	}

	fs.unlink(filename);

	result({
		"error": 0,
		"text": "Success",
		"resultCode": 0,
		"resultText": "We need to figure out how to upload the pcap"
	});
%}
