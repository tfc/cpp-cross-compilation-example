#include <iomanip>
#include <iostream>
#include <memory>
#include <optional>
#include <sstream>
#include <vector>

#include <boost/chrono.hpp>

#include <openssl/evp.h>

std::optional<std::string> sha256_stream(std::istream &is,
                                         const size_t buffer_size = 4096) {
  std::vector<char> buffer(buffer_size);

  std::unique_ptr<EVP_MD_CTX, void (*)(EVP_MD_CTX *)> md_context{
      EVP_MD_CTX_new(), EVP_MD_CTX_free};

  if (!EVP_DigestInit_ex(md_context.get(), EVP_sha256(), nullptr)) {
    std::cerr << "EVP_DigestInit_ex failed\n";
    return {};
  }

  while (is.read(buffer.data(), buffer.size()) || is.gcount() != 0) {
    if (!EVP_DigestUpdate(md_context.get(), buffer.data(), is.gcount())) {
      std::cerr << "EVP_DigestUpdate failed\n";
      return {};
    }
  }

  std::vector<unsigned char> hash(EVP_MAX_MD_SIZE);
  unsigned int hash_length;
  if (!EVP_DigestFinal_ex(md_context.get(), hash.data(), &hash_length)) {
    std::cerr << "EVP_DigestFinal_ex failed\n";
    return {};
  }
  hash.resize(hash_length);

  std::stringstream ss;
  ss << std::hex;
  for (const auto &item : hash) {
    ss << std::setw(2) << std::setfill('0') << static_cast<int>(item);
  }
  return {ss.str()};
}

int main() {
  std::ios::sync_with_stdio(false);

  const auto tic{boost::chrono::high_resolution_clock::now()};
  if (const auto res{sha256_stream(std::cin)}) {
    const auto toc{boost::chrono::high_resolution_clock::now()};
    const auto ms{
        boost::chrono::duration_cast<boost::chrono::milliseconds>(toc - tic)};
    std::cout << *res << " " << ms << '\n';
  }

  return 0;
}
