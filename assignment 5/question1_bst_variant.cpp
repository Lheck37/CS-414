//
// CS 414 Assignment 05 - Question 1
// Simple BST using std::variant to simulate pattern matching

#include <variant>
#include <memory>
#include <vector>
#include <iostream>

struct Empty {};
struct Node;

using Tree = std::variant<Empty, std::unique_ptr<Node>>;

struct Node {
    int value;
    Tree left;
    Tree right;
    Node(int v) : value(v), left(Empty{}), right(Empty{}) {}
};

// quick visitor helper
template<class... Ts>
struct Overloaded : Ts... { using Ts::operator()...; };
template<class... Ts> Overloaded(Ts...) -> Overloaded<Ts...>;

Tree make_empty() { return Tree{Empty{}}; }
Tree make_node(int v) { return Tree{std::make_unique<Node>(v)}; }

void insert(Tree& t, int x) {
    std::visit(Overloaded{
        [&](Empty&) { t = make_node(x); },
        [&](std::unique_ptr<Node>& n) {
            if (x < n->value) insert(n->left, x);
            else if (x > n->value) insert(n->right, x);
        }
    }, t);
}

void inorder(const Tree& t, std::vector<int>& out) {
    std::visit(Overloaded{
        [&](const Empty&) {},
        [&](const std::unique_ptr<Node>& n) {
            inorder(n->left, out);
            out.push_back(n->value);
            inorder(n->right, out);
        }
    }, t);
}

void preorder(const Tree& t, std::vector<int>& out) {
    std::visit(Overloaded{
        [&](const Empty&) {},
        [&](const std::unique_ptr<Node>& n) {
            out.push_back(n->value);
            preorder(n->left, out);
            preorder(n->right, out);
        }
    }, t);
}

void postorder(const Tree& t, std::vector<int>& out) {
    std::visit(Overloaded{
        [&](const Empty&) {},
        [&](const std::unique_ptr<Node>& n) {
            postorder(n->left, out);
            postorder(n->right, out);
            out.push_back(n->value);
        }
    }, t);
}

int main() {
    Tree t = make_empty();
    for (int x : {5, 2, 8, 1, 3, 7, 9}) insert(t, x);

    std::vector<int> v;
    inorder(t, v);
    std::cout << "inorder:   ";
    for (auto x : v) std::cout << x << ' ';
    std::cout << "\n";

    v.clear();
    preorder(t, v);
    std::cout << "preorder:  ";
    for (auto x : v) std::cout << x << ' ';
    std::cout << "\n";

    v.clear();
    postorder(t, v);
    std::cout << "postorder: ";
    for (auto x : v) std::cout << x << ' ';
    std::cout << "\n";
}
