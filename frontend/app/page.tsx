import Twin from '@/components/twin';

export default function Home() {
  return (
    <main className="min-h-screen bg-gradient-to-br from-indigo-50 via-white to-cyan-50">
      <div className="container mx-auto px-4 py-8">
        <div className="max-w-5xl mx-auto">
          {/* Hero Section */}
          <div className="text-center mb-12">
            <div className="inline-flex items-center justify-center w-20 h-20 bg-gradient-to-r from-indigo-500 to-purple-600 rounded-full mb-6 shadow-lg">
              <span className="text-2xl font-bold text-white">N</span>
            </div>
            <h1 className="text-5xl font-bold bg-gradient-to-r from-indigo-600 via-purple-600 to-cyan-600 bg-clip-text text-transparent mb-4">
              Naveen&apos;s Digital Twin
            </h1>
            <p className="text-xl text-gray-600 mb-2">
              Your AI-powered course companion
            </p>
            <p className="text-sm text-gray-500">
              Powered by advanced AI • Deployed on AWS • Built with Next.js
            </p>
          </div>

          {/* Chat Interface */}
          <div className="h-[700px] shadow-2xl rounded-2xl overflow-hidden border border-gray-200">
            <Twin />
          </div>

          {/* Footer */}
          <footer className="mt-12 text-center">
            <div className="flex items-center justify-center space-x-6 text-sm text-gray-500 mb-4">
              <span className="flex items-center space-x-2">
                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
                <span>Live & Connected</span>
              </span>
              <span>•</span>
              <span>AI/ML Engineer</span>
              <span>•</span>
              <span>Indiana University</span>
            </div>
            <p className="text-xs text-gray-400">
              Built with ❤️ using FastAPI, Next.js, and AWS
            </p>
          </footer>
        </div>
      </div>
    </main>
  );
}