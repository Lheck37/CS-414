#include <iostream>
#include <vector>
#include <algorithm>
#include <chrono>
#include <string>

// Simple helper to print a vector
void print_vector(const std::vector<int> &data) {
    for (int x : data) {
        std::cout << x << " ";
    }
    std::cout << "\n";
}

// Abstract base class (strategy interface)
class SortStrategy {
public:
    virtual ~SortStrategy() = default;
    virtual void sort(std::vector<int> &data) = 0;
};

// -------------------- BubbleSort --------------------
class BubbleSort : public SortStrategy {
public:
    void sort(std::vector<int> &data) override {
        bool swapped = true;
        std::size_t n = data.size();
        while (swapped) {
            swapped = false;
            for (std::size_t i = 1; i < n; ++i) {
                if (data[i - 1] > data[i]) {
                    std::swap(data[i - 1], data[i]);
                    swapped = true;
                }
            }
            if (n > 0) {
                --n;
            }
        }
    }
};

// -------------------- QuickSort --------------------
class QuickSort : public SortStrategy {
private:
    void quicksort(std::vector<int> &data, int left, int right) {
        if (left >= right) return;

        int i = left;
        int j = right;
        int pivot = data[(left + right) / 2];

        while (i <= j) {
            while (data[i] < pivot) ++i;
            while (data[j] > pivot) --j;
            if (i <= j) {
                std::swap(data[i], data[j]);
                ++i;
                --j;
            }
        }

        if (left < j) quicksort(data, left, j);
        if (i < right) quicksort(data, i, right);
    }

public:
    void sort(std::vector<int> &data) override {
        if (!data.empty()) {
            quicksort(data, 0, static_cast<int>(data.size()) - 1);
        }
    }
};

// -------------------- MergeSort --------------------
class MergeSort : public SortStrategy {
private:
    void merge(std::vector<int> &data, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;

        std::vector<int> L(n1), R(n2);

        for (int i = 0; i < n1; ++i) L[i] = data[left + i];
        for (int j = 0; j < n2; ++j) R[j] = data[mid + 1 + j];

        int i = 0, j = 0, k = left;
        while (i < n1 && j < n2) {
            if (L[i] <= R[j]) {
                data[k++] = L[i++];
            } else {
                data[k++] = R[j++];
            }
        }
        while (i < n1) data[k++] = L[i++];
        while (j < n2) data[k++] = R[j++];
    }

    void mergesort(std::vector<int> &data, int left, int right) {
        if (left >= right) return;
        int mid = left + (right - left) / 2;
        mergesort(data, left, mid);
        mergesort(data, mid + 1, right);
        merge(data, left, mid, right);
    }

public:
    void sort(std::vector<int> &data) override {
        if (!data.empty()) {
            mergesort(data, 0, static_cast<int>(data.size()) - 1);
        }
    }
};

// -------------------- SortContext --------------------
class SortContext {
private:
    SortStrategy *strategy; // we just borrow; lifetime is managed in main

public:
    SortContext() : strategy(nullptr) {}

    void set_strategy(SortStrategy *s) {
        strategy = s;
    }

    // Wraps the call and also times it
    void execute_strategy(std::vector<int> &data) {
        if (!strategy) {
            std::cerr << "No sorting strategy set.\n";
            return;
        }

        auto start = std::chrono::high_resolution_clock::now();
        strategy->sort(data);
        auto end = std::chrono::high_resolution_clock::now();

        std::chrono::duration<double, std::milli> ms = end - start;
        std::cout << "Sorted in " << ms.count() << " ms\n";
    }
};

int main(int argc, char *argv[]) {
    // Small sample input – you can change this or read from stdin if you want
    std::vector<int> data = {5, 2, 9, 1, 5, 6};

    std::cout << "Original: ";
    print_vector(data);

    // Concrete strategies live on the stack
    BubbleSort bubble;
    QuickSort quick;
    MergeSort merge;

    SortContext context;

    // Choose strategy from command line:
    // ./a.out bubble
    // ./a.out quick
    // ./a.out merge
    std::string choice = "bubble"; // default

    if (argc >= 2) {
        choice = argv[1];
    }

    if (choice == "bubble") {
        std::cout << "Using BubbleSort...\n";
        context.set_strategy(&bubble);
    } else if (choice == "quick") {
        std::cout << "Using QuickSort...\n";
        context.set_strategy(&quick);
    } else if (choice == "merge") {
        std::cout << "Using MergeSort...\n";
        context.set_strategy(&merge);
    } else {
        std::cout << "Unknown strategy '" << choice
                  << "', falling back to BubbleSort.\n";
        context.set_strategy(&bubble);
    }

    context.execute_strategy(data);

    std::cout << "Result:   ";
    print_vector(data);

    // Just to show that we can easily reuse the same context with
    // a different strategy:
    std::cout << "\nSwitching strategy to QuickSort.\n";
    data = {5, 2, 9, 1, 5, 6}; // reset
    context.set_strategy(&quick);
    context.execute_strategy(data);
    std::cout << "Result:   ";
    print_vector(data);

    return 0;
}
