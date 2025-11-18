"""
BudayaGo Personality Quiz
Kuis untuk menentukan archetype berdasarkan dimensi kepribadian
"""

import json
import os
from typing import Dict, List
from datetime import datetime

class PersonalityQuiz:
    def __init__(self, json_file: str, user_name: str):
        """Initialize quiz dengan file JSON"""
        self.json_file = json_file
        self.user_name = user_name
        self.questions = []
        self.scores = {
            "spirituality": 0,
            "courage": 0,
            "empathy": 0,
            "logic": 0,
            "creativity": 0,
            "social": 0,
            "principle": 0
        }
        self.max_scores = {
            "spirituality": 0,
            "courage": 0,
            "empathy": 0,
            "logic": 0,
            "creativity": 0,
            "social": 0,
            "principle": 0
        }
        self.load_questions()
        self.calculate_max_scores()
    
    def load_questions(self):
        """Load pertanyaan dari file JSON"""
        try:
            with open(self.json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                self.questions = data.get('questions', [])
            print(f"Berhasil memuat {len(self.questions)} pertanyaan\n")
        except FileNotFoundError:
            print(f"Error: File '{self.json_file}' tidak ditemukan!")
            exit(1)
        except json.JSONDecodeError:
            print(f"Error: File '{self.json_file}' bukan format JSON yang valid!")
            exit(1)
    
    def calculate_max_scores(self):
        """Hitung skor maksimal untuk setiap dimensi"""
        for question in self.questions:
            for option_key, option_data in question['options'].items():
                weights = option_data.get('weights', {})
                for dimension, weight in weights.items():
                    if dimension in self.max_scores:
                        self.max_scores[dimension] += weight
        
        print("Skor Maksimal Per Dimensi:")
        for dimension, max_score in self.max_scores.items():
            print(f"   {dimension.capitalize()}: {max_score}")
        print()
    
    def display_question(self, question: Dict, question_num: int):
        """Tampilkan pertanyaan dan opsi jawaban"""
        print("=" * 80)
        print(f"PERTANYAAN {question_num}/{len(self.questions)}")
        print("=" * 80)
        print(f"\n{question['text']}\n")
        
        options = question['options']
        for key in sorted(options.keys()):
            option = options[key]
            print(f"  {key}. {option['text']}")
        print()
    
    def get_user_choice(self, valid_options: List[str]) -> str:
        """Dapatkan pilihan user dengan validasi"""
        while True:
            choice = input("Pilih jawaban (A/B/C/D): ").strip().upper()
            if choice in valid_options:
                return choice
            print(f"Pilihan tidak valid! Pilih salah satu: {', '.join(valid_options)}")
    
    def add_scores(self, weights: Dict[str, int]):
        """Tambahkan skor berdasarkan weights"""
        for dimension, weight in weights.items():
            if dimension in self.scores:
                self.scores[dimension] += weight
    
    def calculate_percentages(self) -> Dict[str, float]:
        """Hitung persentase skor untuk setiap dimensi"""
        percentages = {}
        for dimension in self.scores.keys():
            max_score = self.max_scores[dimension]
            if max_score > 0:
                percentage = (self.scores[dimension] / max_score) * 100
                percentages[dimension] = round(percentage, 2)
            else:
                percentages[dimension] = 0.0
        return percentages
    
    def display_results(self):
        """Tampilkan hasil akhir"""
        print("\n" + "=" * 80)
        print("HASIL KUIS KEPRIBADIAN BUDAYAGO")
        print("=" * 80)
        
        percentages = self.calculate_percentages()
        
        print(f"\nNama: {self.user_name}")
        print("\nSkor Per Dimensi:\n")
        print(f"{'Dimensi':<15} {'Skor':<10} {'Maks':<10} {'Persentase':<15} {'Bar Chart'}")
        print("-" * 80)
        
        # Sort by percentage (descending)
        sorted_dimensions = sorted(percentages.items(), key=lambda x: x[1], reverse=True)
        
        for dimension, percentage in sorted_dimensions:
            score = self.scores[dimension]
            max_score = self.max_scores[dimension]
            bar = "#" * int(percentage / 2)  # Scale to 50 chars max
            
            print(f"{dimension.capitalize():<15} {score:<10} {max_score:<10} {percentage:>6.2f}%       {bar}")
        
        print("\n" + "=" * 80)
        
        # Dimensi dominan
        dominant_dimension = sorted_dimensions[0]
        print(f"\nDIMENSI DOMINAN: {dominant_dimension[0].upper()} ({dominant_dimension[1]:.2f}%)")
        
        # Interpretasi sederhana
        self.display_interpretation(dominant_dimension[0])
        
        print("\n" + "=" * 80)
    
    def display_interpretation(self, dominant_dimension: str):
        """Tampilkan interpretasi archetype berdasarkan dimensi dominan"""
        interpretations = {
            "spirituality": "Kamu memiliki jiwa spiritual yang kuat, terhubung dengan alam dan roh leluhur.",
            "courage": "Kamu adalah pribadi yang berani, siap menghadapi tantangan dengan kepala tegak.",
            "empathy": "Kamu memiliki hati yang lembut, selalu peduli dengan perasaan orang lain.",
            "logic": "Kamu adalah pemikir yang analitis, selalu menggunakan logika dalam setiap keputusan.",
            "creativity": "Kamu adalah jiwa kreatif, penuh imajinasi dan ide-ide segar.",
            "social": "Kamu adalah pribadi sosial, mudah bergaul dan menjaga harmoni kelompok.",
            "principle": "Kamu menjunjung tinggi prinsip dan kebenaran, tidak mudah goyah."
        }
        
        print(f"\n{interpretations.get(dominant_dimension, 'Kepribadian unik!')}")
    
    def run(self):
        """Jalankan kuis"""
        print("\n" + "=" * 80)
        print("SELAMAT DATANG DI KUIS KEPRIBADIAN BUDAYAGO")
        print("=" * 80)
        print(f"\nHalo, {self.user_name}!")
        print("\nJawab 15 pertanyaan untuk menemukan archetype kepribadianmu!")
        print("Setiap jawaban akan menambah poin pada dimensi kepribadian tertentu.\n")
        input("Tekan ENTER untuk memulai...")
        print()
        
        # Loop through all questions
        for i, question in enumerate(self.questions, 1):
            self.display_question(question, i)
            
            valid_options = list(question['options'].keys())
            choice = self.get_user_choice(valid_options)
            
            # Add scores
            weights = question['options'][choice]['weights']
            self.add_scores(weights)
            
            print(f"Jawaban tersimpan!\n")
        
        # Display final results
        self.display_results()
        
        # Auto save results
        self.save_results()
    
    def save_results(self):
        """Simpan hasil ke file TXT dan JSON"""
        # Create test_result directory if not exists
        script_dir = os.path.dirname(os.path.abspath(__file__))
        test_result_dir = os.path.join(script_dir, "test_result")
        
        # Create user folder
        user_folder = os.path.join(test_result_dir, self.user_name)
        os.makedirs(user_folder, exist_ok=True)
        
        # Get timestamp
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        percentages = self.calculate_percentages()
        sorted_dimensions = sorted(percentages.items(), key=lambda x: x[1], reverse=True)
        dominant_dimension = sorted_dimensions[0]
        
        # 1. Save detailed TXT file
        txt_filename = os.path.join(user_folder, "hasil_detail.txt")
        with open(txt_filename, 'w', encoding='utf-8') as f:
            f.write("=" * 80 + "\n")
            f.write("HASIL KUIS KEPRIBADIAN BUDAYAGO\n")
            f.write("=" * 80 + "\n\n")
            
            f.write(f"Nama          : {self.user_name}\n")
            f.write(f"Tanggal       : {timestamp}\n")
            f.write(f"Total Soal    : {len(self.questions)}\n\n")
            
            f.write("=" * 80 + "\n")
            f.write("STATISTIK DETAIL\n")
            f.write("=" * 80 + "\n\n")
            
            f.write("Skor Per Dimensi:\n\n")
            f.write(f"{'Dimensi':<15} {'Skor':<10} {'Maks':<10} {'Persentase':<15} {'Chart'}\n")
            f.write("-" * 80 + "\n")
            
            for dimension, percentage in sorted_dimensions:
                score = self.scores[dimension]
                max_score = self.max_scores[dimension]
                bar = "#" * int(percentage / 2)  # Scale to 50 chars max
                f.write(f"{dimension.capitalize():<15} {score:<10} {max_score:<10} {percentage:>6.2f}%       {bar}\n")
            
            f.write("\n" + "=" * 80 + "\n")
            f.write("PERHITUNGAN\n")
            f.write("=" * 80 + "\n\n")
            
            for dimension, percentage in sorted_dimensions:
                score = self.scores[dimension]
                max_score = self.max_scores[dimension]
                f.write(f"{dimension.capitalize():<15}: ({score} / {max_score}) x 100 = {percentage:.2f}%\n")
            
            f.write("\n" + "=" * 80 + "\n")
            f.write("HASIL AKHIR\n")
            f.write("=" * 80 + "\n\n")
            
            f.write(f"DIMENSI DOMINAN: {dominant_dimension[0].upper()} ({dominant_dimension[1]:.2f}%)\n\n")
            
            interpretations = {
                "spirituality": "Kamu memiliki jiwa spiritual yang kuat, terhubung dengan alam dan roh leluhur.",
                "courage": "Kamu adalah pribadi yang berani, siap menghadapi tantangan dengan kepala tegak.",
                "empathy": "Kamu memiliki hati yang lembut, selalu peduli dengan perasaan orang lain.",
                "logic": "Kamu adalah pemikir yang analitis, selalu menggunakan logika dalam setiap keputusan.",
                "creativity": "Kamu adalah jiwa kreatif, penuh imajinasi dan ide-ide segar.",
                "social": "Kamu adalah pribadi sosial, mudah bergaul dan menjaga harmoni kelompok.",
                "principle": "Kamu menjunjung tinggi prinsip dan kebenaran, tidak mudah goyah."
            }
            
            f.write(f"Interpretasi:\n{interpretations.get(dominant_dimension[0], 'Kepribadian unik!')}\n")
            
            f.write("\n" + "=" * 80 + "\n")
            f.write("ASCII CHART\n")
            f.write("=" * 80 + "\n\n")
            
            # Create ASCII bar chart
            max_bar_length = 50
            for dimension, percentage in sorted_dimensions:
                bar = "#" * int(percentage / 2)
                f.write(f"{dimension.capitalize():<15} | {bar} {percentage:.1f}%\n")
        
        # 2. Save JSON file
        json_filename = os.path.join(user_folder, "hasil.json")
        result_data = {
            "nama": self.user_name,
            "timestamp": timestamp,
            "dimensi": {}
        }
        
        for dimension in self.scores.keys():
            result_data["dimensi"][dimension] = {
                "score": self.scores[dimension],
                "max_score": self.max_scores[dimension],
                "percentage": percentages[dimension]
            }
        
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump(result_data, f, indent=2, ensure_ascii=False)
        
        print(f"\nHasil tersimpan di folder: {user_folder}")
        print(f"  - {os.path.basename(txt_filename)} (statistik detail)")
        print(f"  - {os.path.basename(json_filename)} (format JSON)")


def main():
    """Main function"""
    # Path to JSON file (di folder questions)
    questions = "questions5.json"
    script_dir = os.path.dirname(os.path.abspath(__file__))
    json_file = os.path.join(script_dir, "questions", questions)
    
    # Check if file exists
    if not os.path.exists(json_file):
        print(f"Error: File {questions} tidak ditemukan!")
        print(f"   Mencari di: {json_file}")
        print(f"   Pastikan file berada di folder 'questions'.")
        return
    
    # Get user name
    print("\n" + "=" * 80)
    print("KUIS KEPRIBADIAN BUDAYAGO")
    print("=" * 80)
    user_name = input("\nMasukkan nama Anda: ").strip()
    
    if not user_name:
        print("Nama tidak boleh kosong!")
        return
    
    # Run quiz
    quiz = PersonalityQuiz(json_file, user_name)
    quiz.run()
    
    print("\nTerima kasih telah mengikuti kuis BudayaGo!")


if __name__ == "__main__":
    main()
