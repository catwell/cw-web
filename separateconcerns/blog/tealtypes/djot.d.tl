local record M
    enum NodeTag
        "doc"
        "raw_block"
        "para"
        "blockquote"
        "div"
        "section"
        "heading"
        "thematic_break"
        "code_block"
        "table"
        "row"
        "cell"
        "caption"
        "list"
        "list_item"
        "term"
        "definition"
        "definition_list_item"
        "reference_definition"
        "footnote_reference"
        "raw_inline"
        "str"
        "softbreak"
        "hardbreak"
        "nbsp"
        "verbatim"
        "link"
        "url"
        "email"
        "image"
        "span"
        "mark"
        "insert"
        "delete"
        "subscript"
        "superscript"
        "emph"
        "strong"
        "double_quoted"
        "single_quoted"
        "left_double_quote"
        "right_double_quote"
        "left_single_quote"
        "right_single_quote"
        "ellipses"
        "em_dash"
        "en_dash"
        "symbol"
        "math"
    end

    record Node
        t: NodeTag
        s: string -- string content for leaf nodes
        c: {Node} -- children nodes
        format: string -- for raw_block, e.g., "lua-meta"
        destination: string -- for links and images
        level: integer -- for headings
    end

    interface IHandle
        write: function(self: IHandle, s: string)
    end

    interface IRenderer
        out: function(string)
        render: function(self, Node, IHandle)

        doc: function(self, Node)
        raw_block: function(self, Node)
        para: function(self, Node)
        blockquote: function(self, Node)
        div: function(self, Node)
        section: function(self, Node)
        heading: function(self, Node)
        thematic_break: function(self, Node)
        code_block: function(self, Node)
        table: function(self, Node)
        row: function(self, Node)
        cell: function(self, Node)
        caption: function(self, Node)
        list: function(self, Node)
        list_item: function(self, Node)
        term: function(self, Node)
        definition: function(self, Node)
        definition_list_item: function(self, Node)
        reference_definition: function(self, Node)
        footnote_reference: function(self, Node)
        raw_inline: function(self, Node)
        str: function(self, Node)
        softbreak: function(self, Node)
        hardbreak: function(self, Node)
        nbsp: function(self, Node)
        verbatim: function(self, Node)
        link: function(self, Node)
        url: function(self, Node)
        email: function(self, Node)
        image: function(self, Node)
        span: function(self, Node)
        mark: function(self, Node)
        insert: function(self, Node)
        delete: function(self, Node)
        subscript: function(self, Node)
        superscript: function(self, Node)
        emph: function(self, Node)
        strong: function(self, Node)
        double_quoted: function(self, Node)
        single_quoted: function(self, Node)
        left_double_quote: function(self, Node)
        right_double_quote: function(self, Node)
        left_single_quote: function(self, Node)
        right_single_quote: function(self, Node)
        ellipses: function(self, Node)
        em_dash: function(self, Node)
        en_dash: function(self, Node)
        symbol: function(self, Node)
        math: function(self, Node)
    end

    parse: function(string): Node
end

return M
