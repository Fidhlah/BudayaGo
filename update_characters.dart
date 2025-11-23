import 'package:supabase_flutter/supabase_flutter.dart';

/// Script untuk update characters database
/// Run dengan: dart run update_characters.dart
void main() async {
  print('==========================================');
  print('UPDATE CHARACTERS DATABASE');
  print('==========================================\n');

  // Gunakan credentials dari SupabaseConfig Anda
  const supabaseUrl = 'https://pxbpgqceblkoununhmos.supabase.co';
  const supabaseKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'; // Ganti dengan key Anda

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  final supabase = Supabase.instance.client;

  try {
    print('🔄 Updating Ciung Wanara...');
    await supabase
        .from('characters')
        .update({
          'spirituality': 0.00,
          'courage': 36.36,
          'empathy': 18.75,
          'logic': 30.00,
          'creativity': 12.50,
          'social': 0.00,
          'principle': 58.33,
        })
        .eq('name', 'Ciung Wanara');

    print('🔄 Updating Lutung Kasarung...');
    await supabase
        .from('characters')
        .update({
          'spirituality': 20.00,
          'courage': 18.18,
          'empathy': 56.25,
          'logic': 10.00,
          'creativity': 0.00,
          'social': 44.44,
          'principle': 25.00,
        })
        .eq('name', 'Lutung Kasarung');

    print('🔄 Updating Purbasari...');
    await supabase
        .from('characters')
        .update({
          'spirituality': 30.00,
          'courage': 18.18,
          'empathy': 43.75,
          'logic': 0.00,
          'creativity': 0.00,
          'social': 22.22,
          'principle': 50.00,
        })
        .eq('name', 'Purbasari');

    print('🔄 Updating Sawerigading...');
    await supabase
        .from('characters')
        .update({
          'spirituality': 10.00,
          'courage': 81.82,
          'empathy': 25.00,
          'logic': 10.00,
          'creativity': 0.00,
          'social': 22.22,
          'principle': 25.00,
        })
        .eq('name', 'Sawerigading');

    print('🔄 Updating Sengeda...');
    await supabase
        .from('characters')
        .update({
          'spirituality': 40.00,
          'courage': 18.18,
          'empathy': 43.75,
          'logic': 20.00,
          'creativity': 12.50,
          'social': 22.22,
          'principle': 25.00,
        })
        .eq('name', 'Sengeda');

    print('🔄 Updating Si Penyumpit...');
    await supabase
        .from('characters')
        .update({
          'spirituality': 10.00,
          'courage': 36.36,
          'empathy': 31.25,
          'logic': 30.00,
          'creativity': 12.50,
          'social': 11.11,
          'principle': 41.67,
        })
        .eq('name', 'Si Penyumpit');

    print('🔄 Updating Sultan Domas...');
    await supabase
        .from('characters')
        .update({
          'spirituality': 20.00,
          'courage': 27.27,
          'empathy': 37.50,
          'logic': 30.00,
          'creativity': 25.00,
          'social': 11.11,
          'principle': 25.00,
        })
        .eq('name', 'Sultan Domas');

    print('🔄 Updating Timun Mas...');
    await supabase
        .from('characters')
        .update({
          'spirituality': 30.00,
          'courage': 27.27,
          'empathy': 31.25,
          'logic': 40.00,
          'creativity': 25.00,
          'social': 11.11,
          'principle': 16.67,
        })
        .eq('name', 'Timun Mas');

    print('\n✅ All characters updated successfully!');
    print('\nVerifying changes...');

    final result = await supabase
        .from('characters')
        .select(
          'name, spirituality, courage, empathy, logic, creativity, social, principle',
        )
        .order('name');

    print('\n📊 Updated Characters:');
    print('=' * 80);
    for (var char in result) {
      print(
        '${char['name'].toString().padRight(20)} | '
        'Spi: ${char['spirituality'].toString().padLeft(5)} | '
        'Cou: ${char['courage'].toString().padLeft(5)} | '
        'Emp: ${char['empathy'].toString().padLeft(5)} | '
        'Log: ${char['logic'].toString().padLeft(5)}',
      );
    }
    print('=' * 80);
    print('\n🎉 Database update complete!');
  } catch (e) {
    print('\n❌ Error updating database: $e');
  }
}
