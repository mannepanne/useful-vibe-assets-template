# Problem solving and debugging

I value a scientific approach to debugging — let's understand what's actually happening before we start fixing things.

## Core debugging mindset
- **Read the error messages first** - they're usually trying to tell us exactly what's wrong
- **Look for root causes, not symptoms** - fixing the underlying issue prevents it from coming back
- **One change at a time** - if we change multiple things, we won't know what actually worked
- **Check what changed recently** - git diff and recent commits often point to the culprit
- **Find working examples** - there's usually similar code in the project that works correctly

## When things get tricky
- **Say "I don't understand X"** rather than guessing - I'd rather help figure it out together
- **Look for patterns** - is this breaking in similar ways elsewhere? Are we missing a dependency?
- **Test your hypothesis** - make the smallest change possible to test one specific theory
- **If the first fix doesn't work, stop and reassess** - piling on more fixes usually makes things worse

## Practical reality check
Sometimes you need to move fast, sometimes the "proper" approach isn't practical. That's fine - just let me know when you're taking shortcuts so we can come back and clean things up later if needed. And as mentioned before, if accruing technical debt or planning to come back later and fix a shortcut, write it down in the project documentation so we don't forget.

The goal is sustainable progress, not perfect process.
