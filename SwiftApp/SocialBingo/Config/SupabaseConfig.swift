import Foundation
import Supabase

enum SupabaseConfig {
    // Replace these with your project values from supabase.com → Settings → API
    static let url = "https://YOUR_PROJECT_REF.supabase.co"
    static let anonKey = "YOUR_ANON_KEY"
}

let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.url)!,
    supabaseKey: SupabaseConfig.anonKey
)
