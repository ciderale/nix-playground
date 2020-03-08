# Example Presentation

---

# A title

Generate slideshows from markdown.

## A Subtitle

- Bullet points
  - More
- Others

> Quotes

### Subsub title?

---

# Images and Code Samples

![python](http://i.imgur.com/bc2xk.png)


```python
def log(self, message, level='notice'):
    if self.logger and not callable(self.logger):
        raise ValueError(u"Invalid logger set, must be a callable")

    if self.verbose and self.logger:
        self.logger(message, level)
```

---

# Special Features (like speaker notes)

unclear if that is currently supported?

---

# Running

Start a previewer app
> marp -p -w sample.md

Compile to html
> marp sample.md

Compile to pdf
> marp sample.md -o sample.pdf

