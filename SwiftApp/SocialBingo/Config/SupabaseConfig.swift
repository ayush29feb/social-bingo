import Foundation
import Supabase

enum SupabaseConfig {
    // These are safe to commit. The publishable key is intentionally public —
    // it only grants access based on RLS policies. The secret (service role) key
    // bypasses RLS and must never be used in the app or committed to git.
    static let url = "https://ksctpzxhzkbfmrpyxozv.supabase.co"
    static let anonKey = "sb_publishable_ghJbKx4bCEUSiiBnveS2qA_xV3-Kgsg"
}

let supabase = SupabaseClient(
    supabaseURL: URL(string: SupabaseConfig.url)!,
    supabaseKey: SupabaseConfig.anonKey
)
