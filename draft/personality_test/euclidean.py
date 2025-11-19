"""
Euclidean Distance Calculator
Menghitung jarak euclidean antara hasil personality test
"""

import json
import os
import math

def load_json_from_folder(folder_path):
    """
    Load file hasil.json dari folder
    
    Args:
        folder_path: Path ke folder yang berisi hasil.json
        
    Returns:
        dict: Data JSON atau None jika gagal
    """
    json_path = os.path.join(folder_path, "hasil.json")
    
    if not os.path.exists(json_path):
        return None
    
    try:
        with open(json_path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except Exception as e:
        print(f"Error loading {json_path}: {e}")
        return None

def extract_percentages(json_data):
    """
    Ekstrak persentase dari semua dimensi
    
    Args:
        json_data: Data JSON hasil test
        
    Returns:
        dict: Dictionary berisi persentase per dimensi
    """
    percentages = {}
    
    if 'dimensi' in json_data:
        for dimension, values in json_data['dimensi'].items():
            percentages[dimension] = values.get('percentage', 0.0)
    
    return percentages

def calculate_euclidean_distance(percentages1, percentages2):
    """
    Hitung euclidean distance antara dua set persentase
    
    Formula: sqrt(sum((p1 - p2)^2))
    
    Args:
        percentages1: Dictionary persentase subjek
        percentages2: Dictionary persentase target
        
    Returns:
        float: Jarak euclidean
    """
    # Pastikan kedua dictionary punya dimensi yang sama
    dimensions = set(percentages1.keys()) | set(percentages2.keys())
    
    sum_squared_diff = 0.0
    
    for dim in dimensions:
        p1 = percentages1.get(dim, 0.0)
        p2 = percentages2.get(dim, 0.0)
        sum_squared_diff += (p1 - p2) ** 2
    
    return math.sqrt(sum_squared_diff)

def get_all_test_folders(test_result_dir):
    """
    Dapatkan semua folder di dalam test_result
    
    Args:
        test_result_dir: Path ke folder test_result
        
    Returns:
        list: List nama folder
    """
    if not os.path.exists(test_result_dir):
        return []
    
    folders = []
    for item in os.listdir(test_result_dir):
        item_path = os.path.join(test_result_dir, item)
        if os.path.isdir(item_path):
            folders.append(item)
    
    return sorted(folders)

def save_results(subject_name, results, output_file):
    """
    Simpan hasil perhitungan ke file TXT
    
    Args:
        subject_name: Nama subjek yang dibandingkan
        results: List tuple (nama, distance, percentages)
        output_file: Path file output
    """
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write("=" * 80 + "\n")
        f.write("HASIL PERHITUNGAN EUCLIDEAN DISTANCE\n")
        f.write("=" * 80 + "\n\n")
        
        f.write(f"Subjek: {subject_name}\n")
        f.write(f"Total dibandingkan: {len(results)} profil\n\n")
        
        f.write("=" * 80 + "\n")
        f.write("RANKING KEMIRIPAN (dari paling dekat ke paling jauh)\n")
        f.write("=" * 80 + "\n\n")
        
        for rank, (name, distance, percentages) in enumerate(results, 1):
            f.write(f"{rank}. {name}\n")
            f.write(f"   Euclidean Distance: {distance:.4f}\n")
            f.write(f"   Dimensi:\n")
            
            # Urutkan dimensi berdasarkan persentase
            sorted_dims = sorted(percentages.items(), key=lambda x: x[1], reverse=True)
            for dim, percentage in sorted_dims:
                f.write(f"      - {dim.capitalize():<15}: {percentage:>6.2f}%\n")
            
            f.write("\n")
        
        f.write("=" * 80 + "\n")
        f.write("KETERANGAN\n")
        f.write("=" * 80 + "\n\n")
        f.write("Euclidean Distance:\n")
        f.write("- Semakin kecil nilainya = semakin mirip kepribadiannya\n")
        f.write("- Nilai 0 = identik sempurna\n")
        f.write("- Nilai besar = perbedaan kepribadian signifikan\n\n")
        f.write("Formula: sqrt(sum((p1 - p2)^2)) untuk semua dimensi\n")

def main():
    """
    Main function
    """
    # Setup paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    test_result_dir = os.path.join(script_dir, "test_result")
    
    print("=" * 80)
    print("EUCLIDEAN DISTANCE CALCULATOR - PERSONALITY TEST")
    print("=" * 80)
    print()
    
    # Check if test_result directory exists
    if not os.path.exists(test_result_dir):
        print(f"Error: Folder 'test_result' tidak ditemukan di {script_dir}")
        return
    
    # Get all folders
    folders = get_all_test_folders(test_result_dir)
    
    if not folders:
        print("Tidak ada folder di dalam test_result")
        return
    
    # Display available folders
    print("Folder yang tersedia:")
    print()
    for i, folder in enumerate(folders, 1):
        print(f"  {i}. {folder}")
    print()
    
    # Get user choice
    while True:
        try:
            choice = int(input(f"Pilih subjek (1-{len(folders)}): "))
            if 1 <= choice <= len(folders):
                break
            print(f"Pilihan harus antara 1 dan {len(folders)}")
        except ValueError:
            print("Input harus berupa angka")
    
    subject_folder = folders[choice - 1]
    subject_path = os.path.join(test_result_dir, subject_folder)
    
    print(f"\nMemproses subjek: {subject_folder}")
    print()
    
    # Load subject data
    subject_data = load_json_from_folder(subject_path)
    
    if not subject_data:
        print(f"Error: Tidak dapat memuat hasil.json dari folder {subject_folder}")
        return
    
    subject_percentages = extract_percentages(subject_data)
    
    # Calculate distances with all other folders
    results = []
    
    for folder in folders:
        if folder == subject_folder:
            # Skip subjek itu sendiri
            continue
        
        folder_path = os.path.join(test_result_dir, folder)
        target_data = load_json_from_folder(folder_path)
        
        if not target_data:
            print(f"Warning: Tidak dapat memuat hasil.json dari folder {folder}")
            continue
        
        target_percentages = extract_percentages(target_data)
        distance = calculate_euclidean_distance(subject_percentages, target_percentages)
        
        results.append((folder, distance, target_percentages))
    
    # Sort by distance (ascending)
    results.sort(key=lambda x: x[1])
    
    # Display results
    print("=" * 80)
    print("HASIL PERHITUNGAN")
    print("=" * 80)
    print()
    
    for rank, (name, distance, percentages) in enumerate(results, 1):
        print(f"{rank}. {name:<20} Distance: {distance:.4f}")
    
    print()
    
    # Save to file
    output_file = os.path.join(test_result_dir, f"euclidean_{subject_folder}.txt")
    save_results(subject_folder, results, output_file)
    
    print(f"Hasil disimpan ke: {output_file}")
    print()
    print("Selesai!")

if __name__ == "__main__":
    main()
