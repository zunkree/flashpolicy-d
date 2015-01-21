import vibe.d;


enum DEFAULT_PORT = 843;
enum DEFAULT_BIND = "127.0.0.1";
enum DEFAULT_FILE = "public/flashpolicy.xml";

enum POLICY_FILE_REQ = cast(ubyte[])"<policy-file-request/>\0";


struct policyOpts {
	ushort port;
	string bind;
	string file;
}

policyOpts getPolicyOpts ()
{
	policyOpts opts;
	if (!getOption("port|p", &opts.port, format("bind on port, default %d", DEFAULT_PORT)))
		opts.port = DEFAULT_PORT;
	if (!getOption("bind|b", &opts.bind, format("bind on addr, default \"%s\"", DEFAULT_BIND)))
		opts.bind = DEFAULT_BIND;
	if (!getOption("file|f", &opts.file, format("path to policy.xml, defautl \"%s\"", DEFAULT_FILE)))
		opts.file = DEFAULT_FILE;
	return opts;
}

void handleFlashPolicy(TCPConnection stream, string policy)
{
	ubyte[POLICY_FILE_REQ.length] buf;
	stream.read(buf);
	if (POLICY_FILE_REQ == buf) {
		stream.write(policy);
	}
	stream.close;
}

shared static this()
{
	auto opts = getPolicyOpts();
	string policy = readFileUTF8(opts.file);
	listenTCP(opts.port, stream => handleFlashPolicy(stream, policy), opts.bind);
}
