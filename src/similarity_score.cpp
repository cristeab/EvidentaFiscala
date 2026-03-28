#include <algorithm>
#include <QStringList>
#include <QRegularExpression>

//Token Sort Ratio algorithm

// Helper to normalize and sort tokens using C++23 Ranges
static
QString normalizeAndSort(const QString& input)
{
    auto tokens = input.toLower().split(QRegularExpression("\\s+"), Qt::SkipEmptyParts);

    // C++20/23 Range sort (cleaner syntax)
    std::ranges::sort(tokens);

    return tokens.join(" ");
}

static
int levenshteinDistance(std::string_view s1, std::string_view s2)
{
    const size_t len1 = s1.size();
    const size_t len2 = s2.size();

    std::vector<int> prevCol(len2 + 1);
    std::ranges::iota(prevCol, 0); // Fills 0, 1, 2, ... len2

    for (size_t i = 0; i < len1; ++i) {
        std::vector<int> col(len2 + 1);
        col[0] = static_cast<int>(i + 1);

        for (size_t j = 0; j < len2; ++j) {
            int cost = (s1[i] == s2[j]) ? 0 : 1;
            col[j + 1] = std::min({ col[j] + 1, prevCol[j + 1] + 1, prevCol[j] + cost });
        }
        prevCol = std::move(col);
    }
    return prevCol[len2];
}

double calculateSimilarity(const QString& strA, const QString& strB)
{
    QString sortedA = normalizeAndSort(strA);
    QString sortedB = normalizeAndSort(strB);

    // Using std::string_view for the algorithm to avoid extra copies
    std::string s1 = sortedA.toStdString();
    std::string s2 = sortedB.toStdString();

    int distance = levenshteinDistance(s1, s2);
    size_t maxLen = std::max(s1.length(), s2.length());

    return 1.0 - (static_cast<double>(distance) / maxLen);
}
