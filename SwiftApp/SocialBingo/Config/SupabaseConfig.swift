import Foundation
import Supabase

enum SupabaseConfig {
    // Replace these with your project values from supabase.com → Settings → API
    static let url = "https://ksctpzxhzkbfmrpyxozv.supabase.co"
    static let anonKey = "sb_publishable_ghJbKx4bCEUSiiBnveS2qA_xV3-Kgsg"
}

let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.url)!,
    supabaseKey: SupabaseConfig.anonKey
)
