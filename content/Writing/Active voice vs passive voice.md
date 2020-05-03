Title: Active voice vs passive voice
Date: 2020-04-15
Modified: 2020-04-15
Category: Writing
Tags: writing
Authors: Google
Summary: Active voice vs passive voice

Copied from, https://developers.google.com/tech-writing. 

Active voice vs. passive voice
==============================

**Estimated Time:** 15 minutes

The vast majority of sentences in technical writing should be in active voice. This unit teaches you how to do the following:

-   Distinguish passive voice from active voice.
-   Convert passive voice to active voice because active voice is usually clearer.

First, watch this video, just to get the ball rolling^[1](https://developers.google.com/tech-writing/one/active-voice#Footnote1)^:

Distinguish active voice from passive voice in simple sentences
---------------------------------------------------------------

In an active voice sentence, an actor acts on a target. That is, an active voice sentence follows this formula:

> Active Voice Sentence = actor + verb + target

A passive voice sentence reverses the formula. That is, a passive voice sentence typically follows the following formula:

> Passive Voice Sentence = target + verb + actor

### Active voice example

For example, here's a short, active voice sentence:

> The cat sat on the mat.

-   actor: The cat
-   verb: sat
-   target: the mat

### Passive voice examples

By contrast, here's that same sentence in passive voice:

> The mat was sat on by the cat.

-   target: The mat
-   passive verb: was sat
-   actor: the cat

Some passive voice sentences omit an actor. For example:

> The mat was sat on.

-   actor: *unknown*
-   passive verb: was sat
-   target: the mat

Who or what sat on the mat? A cat? A dog? A T-Rex? Readers can only guess. Good sentences in technical documentation identify who is doing what to whom.

Recognize passive verbs
-----------------------

Passive verbs typically have the following formula:

```
passive verb = form of be + past participle verb

```

Although the preceding formula looks daunting, it is actually pretty simple:

-   A **form of *be*** in a passive verb is typically one of the following words:
    -   is/are
    -   was/were
-   A **past participle verb** is typically a plain verb plus the suffix *ed*. For example, the following are past participle verbs:
    -   interpreted
    -   generated
    -   formed

Unfortunately, some past participle verbs are irregular; that is, the past participle form does not end with the suffix *ed*. For example:

-   sat
-   known
-   frozen

Putting the form of *be* and the past participle together yields passive verbs, such as the following:

-   was interpreted
-   is generated
-   was formed
-   is frozen

If the phrase contains an actor, a preposition ordinarily follows the passive verb. (That preposition is often a key clue to help you spot passive voice.) The following examples combine the passive verb and the preposition:

-   was interpreted as
-   is generated by
-   was formed by
-   is frozen by

### Imperative verbs are typically active

It is easy to mistakenly classify sentences starting with an imperative verb as passive. An **imperative verb** is a command. Many items in numbered lists start with imperative verbs. For example, *Open* and *Set* in the following list are both imperative verbs:

1.  Open the configuration file.
2.  Set the `Frombus` variable to `False`.

Sentences that start with an imperative verb are typically in active voice, even though they do not explicitly mention an actor. Instead, sentences that start with an imperative verb *imply* an actor. The implied actor is **you**.

### Exercise

Mark each of the following sentences as either **Passive** or **Active**:

1.  `MutableInput` provides read-only access.
2.  Read-only access is provided by `MutableInput`.
3.  Performance was measured.
4.  Python was invented by Guido van Rossum in the twentieth century.
5.  David Korn discovered the KornShell quite by accident.
6.  This information is used by the policy enforcement team.
7.  Click the Submit button.
8.  The orbit was calculated by Katherine Johnson.

#### Click the icon to see the answer.

1.  **Active**. MutableInput provides read-only access.
2.  **Passive**. Read-only access is provided by MutableInput.
3.  **Passive**. Performance was measured.
4.  **Passive**. Python was invented by Guido van Rossum in the twentieth century.
5.  **Active**. David Korn discovered the KornShell quite by accident.
6.  **Passive**. This information is used by the policy enforcement team.
7.  **Active**. Click the Submit button. (*Click* is an imperative verb.)
8.  **Passive**. The orbit was calculated by Katherine Johnson.

* * * * *

Distinguish active voice from passive voice in more complex sentences
---------------------------------------------------------------------

Many sentences contain multiple verbs, some of which are active and some of which are passive. For example, the following sentence contains two verbs, both of which are in passive voice:

![A diagram of the following sentence: Code is interpreted by
          Python, but code is compiled by C++.  The first half of the sentence
          (Code is interpreted by Python) is in active voice, where a target
          (Code) is acted on (is interpreted) by the actor (Python).
          The second half of the sentence (code is compiled by C++) is also in
          passive voice, where the target (code) is acted on (is compiled)
          by the actor (C++).](../images/passive-passive.svg)

Here is that same sentence, partially converted to active voice:

![A diagram of the following sentence: Python interprets code,
          but code is compiled by C++.  The first half of the sentence
          (Python interprets code) is in active voice, where an actor
          (Python) acts on (interprets) a target (code). The second half
          of the sentence (code is compiled by C++) is in passive voice,
          where the target (code) is acted on (is compiled) by the
          actor (C++).](../images/active-passive.svg)

And here is that same sentence, now fully converted to active voice:

![A diagram of the following sentence: Python interprets code,
          but C++ compiles code.  The first half of the sentence
          (Python interprets code) is in active voice, where an actor
          (Python) acts on (interprets) a target (code). The second half
          of the sentence (C++ compiles code) is also in active voice,
          where the actor (C++) acts on (compiles) the target (code).](../images/all-active.svg)

### Exercise

Each of the following sentences contains two verbs. Categorize each of the verbs in the following sentences as either active or passive. For example, if the first verb is active and the second is passive, write **Active, Passive**.

1.  The QA team loves ice cream, but their managers prefer sorbet.
2.  Performance metrics are required by the team, though I prefer wild guesses.
3.  When software engineers attempt something new and innovative, a reward should be given.

#### Click the icon to see the answer.

1.  **Active, Active.** The QA team loves ice cream, but their managers prefer sorbet.
2.  **Passive, Active.** Performance metrics are required by the team, though I prefer wild guesses.
3.  **Active, Passive.** When software engineers attempt something new and innovative, a reward should be given.

Prefer active voice to passive voice
------------------------------------

Use the active voice most of the time. Use the passive voice sparingly. Active voice provides the following advantages:

-   Most readers mentally convert passive voice to active voice. Why subject your readers to extra processing time? By sticking to active voice, readers can skip the preprocessor stage and go straight to compilation.
-   Passive voice obfuscates your ideas, turning sentences on their head. Passive voice reports action indirectly.
-   Some passive voice sentences omit an actor altogether, which forces the reader to guess the actor's identity.
-   Active voice is generally shorter than passive voice.

Be bold---be active.

### Scientific research reports (optional material)

The writing in research reports tends to be understated. Here, for example, is one of the most famous passages in twentieth century science writing, from Crick and Watson's 1953 paper in *Nature* entitled, *Molecular Structure of Nucleic Acids: A Structure for Deoxyribose Nucleic Acid*:

> It has not escaped our notice that the specific pairing we have postulated immediately suggests a possible copying mechanism for the genetic material.

The authors are so excited about their discovery that they're whispering it from the rooftops.

Passive voice thrives in a tentative landscape. In research reports, experimenters and their equipment often disappear, leading to passive sentences that start off as follows:

-   It has been suggested that...
-   Data was taken...
-   Statistics were calculated...
-   Results were evaluated.

Do we know who is doing what to whom? No. Does the passive voice somehow make the information more objective? No.

Many scientific journals have embraced active voice. We encourage the remainder to join the quest for clarity.

### Exercise

Rewrite the following passive voice sentences as active voice. Only part of certain sentences are in passive voice; ensure that all parts end up as active voice:

1.  The flags were not parsed by the Mungifier.
2.  A wrapper is generated by the Op registration process.
3.  Only one experiment per layer is selected by the Frombus system.
4.  Quality metrics are identified by asterisks; ampersands identify bad metrics.

#### Click the icon to see the answer.

1.  The Mungifier did not parse the flags.
2.  The Op registration process generates a wrapper.
3.  The Frombus system selects only one experiment per layer.
4.  Asterisks identify quality metrics; ampersands identify bad metrics.