function isTerminal(node) {
  return node.children.length === 0;
}

let str = "";
function printCurrent(derivs, index) {
  for (let i = 0; i < derivs.length; i++) {
    const term = derivs[i];

    if (i === index) {
      str += " <span class='var expand'>" + term.name + "</span> ";
      continue;
    }

    if (isTerminal(term)) {
      if (term.name === "") continue;
      str += " <span class='terminal'>" + term.name + "</span> ";
      if (term.name === ";" || term.name === "{") {
        str += "<br>";
      }
      continue;
    }

    str += " <span class='var'>" + term.name + "</span> ";
  }
  if (index >= 0)
    str += "<br><br>";
}

let currDerivation = data;

while (!currDerivation.every(isTerminal)) {
  let rIndex;
  for (let i = currDerivation.length - 1; i >= 0; i--) {
    // Find the rightmost derivation.
    if (!isTerminal(currDerivation[i])) {
      rIndex = i;
      break;
    }
  }

  // Now that I have rightmost derivation, print the current derivation with underline
  printCurrent(currDerivation, rIndex);

  // Now, remove the rightmost derivation, and replace with its children.
  currDerivation =
    currDerivation.slice(0, rIndex).concat(currDerivation[rIndex].children,
                                           currDerivation.slice(rIndex + 1));
}
printCurrent(currDerivation, -1);
