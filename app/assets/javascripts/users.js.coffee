jQuery ->
  $("a").click ->
    button = undefined
    text = undefined
    button = $(this)
    text = button.context.innerHTML
    console.log(text)
    if text is "Follow"
      $(this).context.innerHTML = "Followed"
      $(this).fadeOut("slow")
    else if text is "Unfollow"
      $(this).context.innerHTML = "Unfollowed"
      $(this).fadeOut("slow")
    else