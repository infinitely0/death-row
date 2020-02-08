from bs4 import BeautifulSoup
import numpy as np
import urllib.request


def scrape():
    url = 'http://www.tdcj.state.tx.us/death_row/dr_executed_offenders.html'
    html = urllib.request.urlopen(url).read()
    soup = BeautifulSoup(html, "html5lib")

    headings = [th.text for th in soup.find_all("th")]
    data = np.array([headings])

    rows = soup.find_all("tr")
    for row in rows[1:]:
        row_info = get_execution(row)
        data = np.concatenate((data, [row_info]))

    data = np.array(data)
    np.savetxt("statements.csv", data, delimiter="|", fmt="%s")


def get_execution(row):
    cells = row.find_all("td")
    row_info = []

    for i, cell in enumerate(cells):
        if i == 2:
            row_info.append(get_statement(cell))
        else:
            row_info.append(cell.text)

    return row_info


def get_statement(cell):
    try:
        url = "http://www.tdcj.state.tx.us/death_row/" + cell.find("a")["href"]
        html = urllib.request.urlopen(url).read()
    except Exception as e:
        print(cell)
        return "Not found"

    soup = BeautifulSoup(html, "html5lib")
    sections = soup.find_all("p")
    for i in range(1, (len(sections) - 1)):
        if 'Last Statement' in sections[i].text:
            return clean(sections[i + 1].text)


def clean(statement):
    return statement.replace('\x92s', '').replace('\xa0', '')


if __name__ == "__main__":
    scrape()
