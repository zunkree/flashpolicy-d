import vibe.d;
import std.array;


enum DEFAULT_PORT =  843;
enum DEFAULT_BIND = "0.0.0.0";
enum DEFAULT_FILE = "public/flashpolicy.xml";

enum POLICY_FILE_REQ = cast(ubyte[])"<policy-file-request/>\0";


struct policyOpts {
	string file = DEFAULT_FILE;
	string[] binds = [DEFAULT_BIND];
	ushort[] ports = [DEFAULT_PORT];
}

policyOpts getPolicyOpts ()
{
	policyOpts opts;
	string ports, binds;
	getOption("file|f", &opts.file, format("path to policy.xml, defautl \"%s\"", DEFAULT_FILE));
	getOption("bind|b", &binds, format("bind on comma separated list of addrs, default %s", DEFAULT_BIND));
	getOption("port|p", &ports, format("bind on comma separated list of ports, default %d", DEFAULT_PORT));
	if (binds) opts.binds = binds.split(",");
	if (ports) opts.ports = ports.split(",").map!(a=>to!ushort(a)).array;
	return opts;
}

void handleFlashPolicy(TCPConnection stream, string policy)
{
	ubyte[POLICY_FILE_REQ.length] buf;
	stream.read(buf);
	if (POLICY_FILE_REQ == buf)
		stream.write(policy);
	stream.close;
}

shared static this()
{
	auto opts = getPolicyOpts();
	string policy = readFileUTF8(opts.file);
	foreach (bind; opts.binds)
		foreach (port; opts.ports)
			listenTCP(port, stream => handleFlashPolicy(stream, policy), bind);
}
